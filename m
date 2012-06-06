Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id B64706B00A9
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 07:36:12 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so13383368obb.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 04:36:12 -0700 (PDT)
Message-ID: <1338982637.3292.63.camel@lappy>
Subject: Re: [PATCH 05/11] mm: frontswap: split frontswap_shrink further to
 eliminate locking games
From: Sasha Levin <levinsasha928@gmail.com>
Date: Wed, 06 Jun 2012 13:37:17 +0200
In-Reply-To: <CAPbh3ruJVJkemK4WqjxQYbXYtD9zdDB3dqrRF916cpw3Ub66ug@mail.gmail.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
	 <1338980115-2394-5-git-send-email-levinsasha928@gmail.com>
	 <CAPbh3ruJVJkemK4WqjxQYbXYtD9zdDB3dqrRF916cpw3Ub66ug@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad@darnok.org
Cc: linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, dan.magenheimer@oracle.com

On Wed, 2012-06-06 at 07:30 -0400, Konrad Rzeszutek Wilk wrote:
> 
> On Jun 6, 2012 6:55 AM, "Sasha Levin" <levinsasha928@gmail.com> wrote:
> >
> > Split frontswap_shrink to eliminate the locking issues in the
> original code.
> 
> Can you describe the locking issue please?

I may have worded that wrong, it's less of an "issue" and more of a
complicated code to deal with locking, specifically the extra local
variable to keep track whether we are locking or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
