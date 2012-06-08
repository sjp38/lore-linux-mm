Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id B05F76B0062
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 18:36:53 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so4009849obb.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 15:36:52 -0700 (PDT)
Message-ID: <1339195083.11360.1.camel@lappy>
Subject: Re: [PATCH v2 00/10] minor frontswap cleanups and tracing support
From: Sasha Levin <levinsasha928@gmail.com>
Date: Sat, 09 Jun 2012 00:38:03 +0200
In-Reply-To: <20120608220422.GA15294@localhost.localdomain>
References: <1339182919-11432-1-git-send-email-levinsasha928@gmail.com>
	 <20120608220422.GA15294@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2012-06-08 at 18:04 -0400, Konrad Rzeszutek Wilk wrote:
> On Fri, Jun 08, 2012 at 09:15:09PM +0200, Sasha Levin wrote:
> > Most of these patches are minor cleanups to the mm/frontswap.c code, the big
> > chunk of new code can be attributed to the new tracing support.
> > 
> > 
> > Changes in v2:
> >  - Rebase to current version
> >  - Address Konrad's comments
> 
> There was one comment that I am not sure if it was emailed and that
> was about adding the "lockdep_assert_held(&swap_lock);".
> 
> You added that in two patches, while the git commit only talks about
> "move that code" . Please remove it out of the "move the code" patches
> and add it as a seperate git commit with an explanation of why it
> is added.

argh, I forgot to comment on that as well. Sorry.

> Otherwise (well, the compile issue that was spotted) the patches
> look great. Could you repost them with those two fixes please?

Will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
