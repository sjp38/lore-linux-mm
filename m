Date: Wed, 4 Jun 2008 11:39:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 00/21] hugetlb multi size, giant hugetlb support, etc
Message-Id: <20080604113911.e5395f1d.akpm@linux-foundation.org>
In-Reply-To: <48468343.2010006@firstfloor.org>
References: <20080603095956.781009952@amd.local0.net>
	<20080604012938.53b1003c.akpm@linux-foundation.org>
	<48468343.2010006@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Wed, 04 Jun 2008 13:57:55 +0200 Andi Kleen <andi@firstfloor.org> wrote:

> > 
> > All pretty straightforward stuff, unless I'm missing something.  But
> > please do spell it out because surely there's stuff in here which I
> > will miss from the implementation and the skimpy changelog.
> 
> It was spelled out in the original 0/0
> 
> Here's a copy
> ftp://ftp.firstfloor.org/pub/ak/gbpages/patches/intro

yeah, like that.

> > Please don't think I'm being anal here - changelogging matters.  It
> > makes review more effective and it allows reviewers to find problems
> > which they would otherwise have overlooked.  btdt, lots of times.
> 
> Hmm, perhaps we need dummy commits for 0/0s. I guess the intro could
> be added to the changelog of the first patch.

Yup.  I always copy the 0/n text into 1/n.  For some reason I often forget
to do it until after I've committed the 1/n.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
