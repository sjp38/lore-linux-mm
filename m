Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BDFA49000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 17:24:35 -0400 (EDT)
Date: Thu, 22 Sep 2011 17:24:32 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: kernel crash
Message-ID: <20110922212432.GB25623@redhat.com>
References: <1316717125.61795.YahooMailClassic@web162017.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1316717125.61795.YahooMailClassic@web162017.mail.bf1.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: M <sah_8@yahoo.com>
Cc: linux-mm@kvack.org

On Thu, Sep 22, 2011 at 11:45:25AM -0700, M wrote:
 > Hi,
 > 
 > I am running Fedora 15 644bit on AMD 64bit arch. After update 3 days ago, kernel started to crash when I submit a heavy computation job. It happened today also with similar type of job. 
 > 
 > I submitted a bug report to https://bugzilla.redhat.com/  d=740613 . They referred me to contact linux memory management group. I have also uploaded my log file in the bug report. I will be very happy to provide more information if required to resolve this issue.
 > 
 > Thanks.

(fixed url is https://bugzilla.redhat.com/show_bug.cgi?id=740613)

Manoj's report here has a system with 32GB of RAM and 40GB of swap
oomkill'ing processes when there seems to be ram still available.

I note the gfp mask of the failing allocations has GFP_HIGHMEM,
and this apparently doesn't happen when he runs 32-bit.

Could that be a clue ?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
