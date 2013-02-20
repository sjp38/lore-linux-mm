Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id A155A6B0005
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 16:06:45 -0500 (EST)
Date: Wed, 20 Feb 2013 13:06:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] tmpfs: fix mempolicy object leaks
Message-Id: <20130220130643.992f7c6e.akpm@linux-foundation.org>
In-Reply-To: <alpine.LNX.2.00.1302201221270.1152@eggly.anvils>
References: <1361344302-26565-1-git-send-email-gthelen@google.com>
	<1361344302-26565-2-git-send-email-gthelen@google.com>
	<alpine.LNX.2.00.1302201221270.1152@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 20 Feb 2013 12:26:26 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> > @@ -2463,19 +2464,23 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
> >  			if (!gid_valid(sbinfo->gid))
> >  				goto bad_val;
> >  		} else if (!strcmp(this_char,"mpol")) {
> > -			if (mpol_parse_str(value, &sbinfo->mpol))
> > +			mpol_put(mpol);
> 
> I haven't tested to check, but don't we need
> 			mpol = NULL;
> here, in case the new option turns out to be bad?

We do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
