Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 7E9366B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 14:45:24 -0400 (EDT)
Received: by ggnf4 with SMTP id f4so146367ggn.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 11:45:23 -0700 (PDT)
Date: Tue, 21 Aug 2012 11:44:39 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 06/15] mm: teach truncate_inode_pages_range() to handle
 non page aligned ranges
In-Reply-To: <50339e0d.69b2340a.50ba.ffff92bcSMTPIN_ADDED@mx.google.com>
Message-ID: <alpine.LSU.2.00.1208211142510.2178@eggly.anvils>
References: <1343376074-28034-1-git-send-email-lczerner@redhat.com> <1343376074-28034-7-git-send-email-lczerner@redhat.com> <alpine.LSU.2.00.1208192144260.2390@eggly.anvils> <alpine.LFD.2.00.1208201221360.3975@vpn-8-6.rdu.redhat.com>
 <alpine.LSU.2.00.1208200812110.25681@eggly.anvils> <50339e0d.69b2340a.50ba.ffff92bcSMTPIN_ADDED@mx.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, 21 Aug 2012, Lukas Czerner wrote:
> On Mon, 20 Aug 2012, Hugh Dickins wrote:
> > 
> > I can see advantages to length, actually: it's often unclear
> > whether "end" is of the "last-of-this" or "start-of-next" variety;
> > in most of mm we are consistent in using end in the start-of-next
> > sense, but here truncate_inode_pages_range() itself has gone for
> > the last-of-this meaning.
> 
> I really do agree with this paragraph and this is why I like the "length"
> argument better. So if there is no objections I'll stick with it and
> fix the other things you've pointed out.

Okay
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
