Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id BE9486B005D
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 07:11:17 -0400 (EDT)
Date: Mon, 10 Sep 2012 13:11:13 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: iwl3945: order 5 allocation during ifconfig up; vm problem?
Message-ID: <20120910111113.GA25159@elf.ucw.cz>
References: <20120909213228.GA5538@elf.ucw.cz>
 <alpine.DEB.2.00.1209091539530.16930@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1209091539530.16930@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: sgruszka@redhat.com, linux-wireless@vger.kernel.org, johannes.berg@intel.com, wey-yi.w.guy@intel.com, ilw@linux.intel.com, Andrew Morton <akpm@osdl.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun 2012-09-09 15:40:55, David Rientjes wrote:
> On Sun, 9 Sep 2012, Pavel Machek wrote:
> 
> > On 3.6.0-rc2+, I tried to turn on the wireless, but got
> > 
> > root@amd:~# ifconfig wlan0 10.0.0.6 up
> > SIOCSIFFLAGS: Cannot allocate memory
> > SIOCSIFFLAGS: Cannot allocate memory
> > root@amd:~# 
> > 
> > It looks like it uses "a bit too big" allocations to allocate
> > firmware...? Order five allocation....
> > 
> > Hmm... then I did "echo 3  > /proc/sys/vm/drop_caches" and now the
> > network works. Is it VM problem that it failed to allocate memory when
> > it was freeable?
> > 
> 
> Do you have CONFIG_COMPACTION enabled?

Yes:

pavel@amd:/data/l/linux-good$ zgrep CONFIG_COMPACTION /proc/config.gz 
CONFIG_COMPACTION=y
								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
