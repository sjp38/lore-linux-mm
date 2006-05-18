Date: Thu, 18 May 2006 15:20:48 +0100
Subject: [PATCH 0/2] Zone boundary alignment fixes    cleanups
Message-ID: <exportbomb.1147962048@pinky>
References: <20060511005952.3d23897c.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andy Whitcroft <apw@shadowen.org>, nickpiggin@yahoo.com.au, haveblue@us.ibm.com, bob.picco@hp.com, mingo@elte.hu, mbligh@mbligh.org, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Sorry for the delay, we've been busy looking to see what is
responsible for the ia64 issues with architecture independant
zone sizing.]

Following this email are two cleanup patches for the
UNALIGNED_ZONE_BOUNDARIES support in -mm.

zone-init-check-and-report-unaligned-zone-boundaries-fix --
  we currently will pointlessly report zones as missaligned even
  though they are empty and will report the first zone which can
  never be missaligned assuming node_mem_map is aligned correctly.

zone-allow-unaligned-zone-boundaries-spelling-fix -- when the
  spelling errors in zone-allow-unaligned-zone-boundaries-spelling
  were fixed the configuration options were not updated.

Both of the above patches slot into the linux-2.6.17-rc4-mm1 patch
set next to their main patches.  Amazingly, they will also apply
on top of linux-2.6.17-rc4-mm1, I don't know what patch has been
taking but it rocks.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
