Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id D43A86B0062
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 14:36:48 -0400 (EDT)
Date: Thu, 7 Jun 2012 14:28:56 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 05/11] mm: frontswap: split frontswap_shrink further to
 eliminate locking games
Message-ID: <20120607182856.GZ9472@phenom.dumpdata.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
 <1338980115-2394-5-git-send-email-levinsasha928@gmail.com>
 <CAPbh3ruJVJkemK4WqjxQYbXYtD9zdDB3dqrRF916cpw3Ub66ug@mail.gmail.com>
 <1338982637.3292.63.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338982637.3292.63.camel@lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: konrad@darnok.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.magenheimer@oracle.com

On Wed, Jun 06, 2012 at 01:37:17PM +0200, Sasha Levin wrote:
> On Wed, 2012-06-06 at 07:30 -0400, Konrad Rzeszutek Wilk wrote:
> > 
> > On Jun 6, 2012 6:55 AM, "Sasha Levin" <levinsasha928@gmail.com> wrote:
> > >
> > > Split frontswap_shrink to eliminate the locking issues in the
> > original code.
> > 
> > Can you describe the locking issue please?
> 
> I may have worded that wrong, it's less of an "issue" and more of a
> complicated code to deal with locking, specifically the extra local
> variable to keep track whether we are locking or not.

So "simplying the locking"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
