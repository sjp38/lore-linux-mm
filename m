Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id DCA376B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 12:48:52 -0400 (EDT)
Received: by yenm8 with SMTP id m8so3703719yen.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 09:48:51 -0700 (PDT)
Date: Fri, 23 Mar 2012 09:48:48 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [GIT PULL] staging: ramster: unbreak my heart
Message-ID: <20120323164848.GB22875@kroah.com>
References: <2d2c494d-64e3-4968-a406-a8ede7eb39bb@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2d2c494d-64e3-4968-a406-a8ede7eb39bb@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, linux-mm@kvack.org

On Fri, Mar 23, 2012 at 09:40:15AM -0700, Dan Magenheimer wrote:
> Hey Greg  --
> 
> The just-merged ramster staging driver was dependent on a cleanup patch in
> cleancache, so was marked CONFIG_BROKEN until that patch could be
> merged.  That cleancache patch is now merged (and the correct SHA of the
> cleancache patch is 3167760f83899ccda312b9ad9306ec9e5dda06d4 rather than
> the one shown in the comment removed in the patch below).
> 
> So remove the CONFIG_BROKEN now and the comment that is no longer true...
> 
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Why do you say "GIT PULL" here, when this is just a single patch?  Odd.

I'll queue this up for sending to Linus after 3.4-rc1 is out, thanks.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
