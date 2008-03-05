Received: by rv-out-0910.google.com with SMTP id f1so1066978rvb.26
        for <linux-mm@kvack.org>; Wed, 05 Mar 2008 05:07:02 -0800 (PST)
Message-ID: <84144f020803050507u38ee01fdif28d27cf032b60c2@mail.gmail.com>
Date: Wed, 5 Mar 2008 15:07:02 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: typo fix in Documentation/vm/slub.txt
In-Reply-To: <47CE95FC.9070307@ap.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <47CE95FC.9070307@ap.jp.nec.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Itaru Kitayama <i-kitayama@ap.jp.nec.com>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 5, 2008 at 2:45 PM, Itaru Kitayama <i-kitayama@ap.jp.nec.com> wrote:
> Change dentry_cache to dentry. If not fixed in upstream, please
>  apply this patch.

This is missing a Signed-off-by line and the patch subject should
follow the format "slub: fix typo in" as per:

  http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt

Can you please fix that and resend to Christoph who maintains the SLUB tree?

                                  Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
