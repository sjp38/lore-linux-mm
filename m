Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 2777A6B0034
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 13:55:32 -0400 (EDT)
Date: Wed, 19 Jun 2013 12:25:36 -0400
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [PATCH 2/2] mmap: allow MAP_HUGETLB for hugetlbfs files
Message-ID: <20130619162536.GB7511@logfs.org>
References: <1371581225-27535-1-git-send-email-joern@logfs.org>
 <1371581225-27535-3-git-send-email-joern@logfs.org>
 <51C107E9.9050900@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <51C107E9.9050900@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, 19 June 2013 09:22:49 +0800, Jianguo Wu wrote:
> 
> We already have is_file_hugepages().

Indeed.  Much nicer now.  Thanks!

JA?rn

--
The grand essentials of happiness are: something to do, something to
love, and something to hope for.
-- Allan K. Chalmers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
