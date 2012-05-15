Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id B68226B00EB
	for <linux-mm@kvack.org>; Tue, 15 May 2012 11:14:50 -0400 (EDT)
Date: Tue, 15 May 2012 17:14:27 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/2 v2] Flexible proportions for BDIs
Message-ID: <20120515151427.GB26579@quack.suse.cz>
References: <1336084760-19534-1-git-send-email-jack@suse.cz>
 <20120507144344.GA13983@localhost>
 <20120509113720.GC5092@quack.suse.cz>
 <20120510073123.GA7523@localhost>
 <20120511145114.GA18227@localhost>
 <20120513032952.GA8099@localhost>
 <20120514212803.GT5353@quack.suse.cz>
 <1337080332.27694.39.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337080332.27694.39.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org

On Tue 15-05-12 13:12:12, Peter Zijlstra wrote:
> On Mon, 2012-05-14 at 23:28 +0200, Jan Kara wrote:
> > So is anybody against merging this?
> 
> I'd like to see the timer disable itself stuff first.. other than that,
> no.
  Ah, my fault. I have the code written already but forgot to send it...
I'll post v3 in a minute.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
