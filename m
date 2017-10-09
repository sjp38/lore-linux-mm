Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C96126B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 18:54:25 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id a43so14589181qta.23
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 15:54:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u184si4059743qkd.263.2017.10.09.15.54.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 15:54:25 -0700 (PDT)
Date: Tue, 10 Oct 2017 00:54:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2] Userfaultfd: Add description for UFFD_FEATURE_SIGBUS
Message-ID: <20171009225422.GF18175@redhat.com>
References: <1507589151-27430-1-git-send-email-prakash.sangappa@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1507589151-27430-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, rppt@linux.vnet.ibm.com, mhocko@suse.com

On Mon, Oct 09, 2017 at 03:45:51PM -0700, Prakash Sangappa wrote:
> Userfaultfd feature UFFD_FEATURE_SIGBUS was merged recently and should
> be available in Linux 4.14 release. This patch is for the manpage
> changes documenting this API.
> 
> Documents the following commit:
> 
> commit 2d6d6f5a09a96cc1fec7ed992b825e05f64cb50e
> Author: Prakash Sangappa <prakash.sangappa@oracle.com>
> Date: Wed Sep 6 16:23:39 2017 -0700
> 
>      mm: userfaultfd: add feature to request for a signal delivery
> 
> Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
