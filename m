Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 582126B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 17:35:43 -0400 (EDT)
Date: Wed, 20 Mar 2013 17:35:26 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1363815326-urchkyxr-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <5148F830.3070601@gmail.com>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5148F830.3070601@gmail.com>
Subject: Re: [RFC][PATCH 0/9] extend hugepage migration
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

On Wed, Mar 20, 2013 at 07:43:44AM +0800, Simon Jeons wrote:
...
> >Easy patch access:
> >   git@github.com:Naoya-Horiguchi/linux.git
> >   branch:extend_hugepage_migration
> >
> >Test code:
> >   git@github.com:Naoya-Horiguchi/test_hugepage_migration_extension.git
> 
> git clone
> git@github.com:Naoya-Horiguchi/test_hugepage_migration_extension.git
> Cloning into test_hugepage_migration_extension...
> Permission denied (publickey).
> fatal: The remote end hung up unexpectedly

Sorry, wrong url.
git://github.com/Naoya-Horiguchi/test_hugepage_migration_extension.git
or
https://github.com/Naoya-Horiguchi/test_hugepage_migration_extension.git
should work.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
