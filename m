Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAGM1IKM025783
	for <linux-mm@kvack.org>; Wed, 16 Nov 2005 17:01:18 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAGM14Ia040674
	for <linux-mm@kvack.org>; Wed, 16 Nov 2005 15:01:04 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAGM1HsQ020540
	for <linux-mm@kvack.org>; Wed, 16 Nov 2005 15:01:17 -0700
Subject: Re: [RFC] sys_punchhole()
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051113150906.GA2193@spitz.ucw.cz>
References: <1131664994.25354.36.camel@localhost.localdomain>
	 <20051110153254.5dde61c5.akpm@osdl.org>
	 <20051113150906.GA2193@spitz.ucw.cz>
Content-Type: text/plain
Date: Wed, 16 Nov 2005 14:01:10 -0800
Message-Id: <1132178470.24066.85.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Andrew Morton <akpm@osdl.org>, andrea@suse.de, hugh@veritas.com, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2005-11-13 at 15:09 +0000, Pavel Machek wrote:
> Hi!
> 
> > > We discussed this in madvise(REMOVE) thread - to add support 
> > > for sys_punchhole(fd, offset, len) to complete the functionality
> > > (in the future).
> > > 
> > > http://marc.theaimsgroup.com/?l=linux-mm&m=113036713810002&w=2
> > > 
> > > What I am wondering is, should I invest time now to do it ?
> > 
> > I haven't even heard anyone mention a need for this in the past 1-2 years.
> 
> Some database people wanted it maybe month ago. It was replaced by some 
> madvise hack...

Hmm. Someone other than me asking for it ? 

I did the madvise() hack and asking to see if any one really needs
sys_punchole().

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
