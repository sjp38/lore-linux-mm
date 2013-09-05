Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id F14F56B0033
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 18:11:41 -0400 (EDT)
Date: Fri, 6 Sep 2013 00:11:40 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/2 v2] mm: allow to set overcommit ratio more precisely
Message-ID: <20130905221140.GA29867@amd.pavel.ucw.cz>
References: <1376925478-15506-1-git-send-email-jmarchan@redhat.com>
 <1376925478-15506-2-git-send-email-jmarchan@redhat.com>
 <52287E66.9010107@redhat.com>
 <52289824.20000@intel.com>
 <5228999B.8010300@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5228999B.8010300@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

hi!

> >> This patch adds the new overcommit_ratio_ppm sysctl variable that
> >> allow to set overcommit ratio with a part per million precision.
> >> The old overcommit_ratio variable can still be used to set and read
> >> the ratio with a 1% precision. That way, overcommit_ratio interface
> >> isn't broken in any way that I can imagine.
> > 
> > Looks like a pretty sane solution.  Could you also make a Documentation/
> > update, please?
> 
> Damn! I forgot. Will do.

Actually... would something like overcommit_bytes be better interface? overcommit_pages?

If system would normally allow allocating "n" pages, with overcommit
it would allow allocating "n + overcommit_pages" pages. That seems
like right granularity...

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
