Date: Wed, 07 May 2003 02:56:26 -0700 (PDT)
Message-Id: <20030507.025626.10317747.davem@redhat.com>
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <3EB8E4CC.8010409@aitel.hist.no>
References: <3EB8DBA0.7020305@aitel.hist.no>
	<1052304024.9817.3.camel@rth.ninka.net>
	<3EB8E4CC.8010409@aitel.hist.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: helgehaf@aitel.hist.no
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

   David S. Miller wrote:
   > On Wed, 2003-05-07 at 03:10, Helge Hafting wrote:
   > 
   >>2.5.69-mm1 is fine, 2.5.69-mm2 panics after a while even under very
   >>light load.
   > 
   > Do you have AF_UNIX built modular?
   
   No, I compile everything into a monolithic kernel.
   I don't even enable module support.
   
Andrew, color me stumped.  mm2/linux.patch doesn't have anything
really interesting in the networking.  Maybe it's something in
the SLAB and/or pgd/pmg re-slabification changes?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
