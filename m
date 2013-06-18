Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id DAF216B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 17:34:25 -0400 (EDT)
Date: Tue, 18 Jun 2013 16:04:33 -0400
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [PATCH 0/2] hugetlb fixes
Message-ID: <20130618200433.GA28198@logfs.org>
References: <1371581225-27535-1-git-send-email-joern@logfs.org>
 <20130618185055.GA27618@logfs.org>
 <20130618132705.c5eb78a20499beb1b769f741@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20130618132705.c5eb78a20499beb1b769f741@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 June 2013 13:27:05 -0700, Andrew Morton wrote:
> On Tue, 18 Jun 2013 14:50:55 -0400 J__rn Engel <joern@logfs.org> wrote:
> 
> > On Tue, 18 June 2013 14:47:03 -0400, Joern Engel wrote:
> > > 
> > > Test program below is failing before these two patches and passing
> > > after.
> > 
> > Actually, do we have a place to stuff kernel tests?  And if not,
> > should we have one?
> 
> Yep, tools/testing/selftests/vm.  It's pretty simple and stupid at
> present - it anything about the framework irritates you, please fix it!

Just did. :)

JA?rn

--
Maintenance in other professions and of other articles is concerned with
the return of the item to its original state; in Software, maintenance
is concerned with moving an item away from its original state.
-- Les Belady

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
