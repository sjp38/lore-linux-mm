From: Philip Prindeville <philipp-9z15yex7P+UJvtFkdXX2HpqQE7yCjDx5@public.gmane.org>
Subject: [PATCH 0/4] arch/x86/platform/geode: enhance and expand support for
 Geode-based platforms, including those using Coreboot
Date: Sun, 18 Dec 2011 13:18:31 -0700
Message-ID: <201112182100.pBIL0Jbr007998@builder.redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-geode-bounces+glpg-linux-geode=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-geode>,
 <mailto:linux-geode-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-geode/>
List-Post: <mailto:linux-geode-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-geode-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-geode>,
 <mailto:linux-geode-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: linux-geode-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Errors-To: linux-geode-bounces+glpg-linux-geode=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Ed Wildgoose <ed-XJavvHiACVh0ubjbjo6WXg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-geode-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Nathan Williams <nathan-NT1X+RKBS/00n/F98K4Iww@public.gmane.org>, David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Patrick Georgi <patrick.georgi-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>, Guy Ellis <guy-NT1X+RKBS/00n/F98K4Iww@public.gmane.org>
List-Id: linux-mm.kvack.org

Many applications running embedded linux use Geode-based single-board
computers. There are many reasons for this, but the low cost bill-of-
materials and the maturity and multiple sourcing of the Geode processor
are amongst the most significant. This collection of patches supplements
the Geode platform support by adding 2 new platforms (Geos and Net5501),
and enhancing one (Alix2) with GPIO-based button support. It also adds
support for detecting Coreboot BIOS and parsing its tables.

Philip Prindeville (4):
  Add support for finding the end-boundary of an E820 region given an  
    address falling in one such region. This is precursory
    functionality for Coreboot loader support.
  Add support for Coreboot BIOS detection. This in turn can be used by 
    platform drivers to verify they are running on the correct
    hardware, as many of the low-volume SBC's (especially in the
    Atom and Geode universe) don't always identify themselves via
    DMI or PCI-ID.
  Trivial platform driver for Traverse Technologies Geos and Geos2    
    single-board computers. Uses Coreboot BIOS to identify platform.   
    Based on progressive revisions of the leds-net5501 driver that    
    was rewritten by Ed Wildgoose as a platform driver.
  Trivial platform driver for Soekris Engineering net5501 single-board 
    computer. Probes well-known locations in ROM for BIOS signature
    to confirm correct platform. Registers 1 LED and 1 GPIO-based
    button (typically used for soft reset).

 Documentation/x86/coreboot.txt    |   31 ++++
 arch/x86/Kconfig                  |   13 ++
 arch/x86/platform/geode/Makefile  |    2 +
 arch/x86/platform/geode/geos.c    |  127 ++++++++++++++++
 arch/x86/platform/geode/net5501.c |  144 ++++++++++++++++++
 drivers/leds/leds-net5501.c       |   97 ------------
 include/linux/coreboot.h          |  182 +++++++++++++++++++++++
 include/linux/ioport.h            |    1 +
 kernel/resource.c                 |   29 ++++
 lib/Kconfig                       |    8 +
 lib/Makefile                      |    1 +
 lib/coreboot.c                    |  290 +++++++++++++++++++++++++++++++++++++
 12 files changed, 828 insertions(+), 97 deletions(-)
 create mode 100644 Documentation/x86/coreboot.txt
 create mode 100644 arch/x86/platform/geode/geos.c
 create mode 100644 arch/x86/platform/geode/net5501.c
 delete mode 100644 drivers/leds/leds-net5501.c
 create mode 100644 include/linux/coreboot.h
 create mode 100644 lib/coreboot.c

-- 
1.7.7.4
