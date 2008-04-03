From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [RFC 01/22] Generic show_mem() implementation
Date: Thu, 3 Apr 2008 13:18:34 +0100
Message-ID: <20080403121834.GA20437@linux-mips.org>
References: <12071688283927-git-send-email-hannes@saeurebad.de> <1207168839586-git-send-email-hannes@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760974AbYDCRU6@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1207168839586-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sourceforge.net, takata@linux-m32r.org, geert@linux-m68k.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org

On Wed, Apr 02, 2008 at 10:40:07PM +0200, Johannes Weiner wrote:

> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>

And also Acked-By: Ralf Baechle <ralf@linux-mips.org>.

Btw, the MIPS part of your patch is not a plain switch from arch to generic
code as the patch comments seem to imply - the arch version was broken for
some configs ...

  Ralf
