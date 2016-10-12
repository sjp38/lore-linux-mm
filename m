Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id A79236B0069
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 23:29:42 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id os4so31689488pac.5
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 20:29:42 -0700 (PDT)
Received: from out0-149.mail.aliyun.com (out0-149.mail.aliyun.com. [140.205.0.149])
        by mx.google.com with ESMTP id d5si3500782pgh.128.2016.10.11.20.29.41
        for <linux-mm@kvack.org>;
        Tue, 11 Oct 2016 20:29:41 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1476229810-26570-1-git-send-email-kandoiruchi@google.com> <1476229810-26570-7-git-send-email-kandoiruchi@google.com>
In-Reply-To: <1476229810-26570-7-git-send-email-kandoiruchi@google.com>
Subject: Re: [RFC 6/6] drivers: staging: ion: add ION_IOC_TAG ioctl
Date: Wed, 12 Oct 2016 11:29:23 +0800
Message-ID: <00b201d22438$d51aaf30$7f500d90$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Ruchi Kandoi' <kandoiruchi@google.com>, gregkh@linuxfoundation.org, arve@android.com, riandrews@android.com, sumit.semwal@linaro.org, arnd@arndb.de, labbott@redhat.com, viro@zeniv.linux.org.uk, jlayton@poochiereds.net, bfields@fieldses.org, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, keescook@chromium.org, mhocko@suse.com, oleg@redhat.com, john.stultz@linaro.org, mguzik@redhat.com, jdanis@google.com, adobriyan@gmail.com, ghackmann@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, dave.hansen@linux.intel.com, dan.j.williams@intel.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, luto@kernel.org, tj@kernel.org, vdavydov.dev@gmail.com, ebiederm@xmission.com, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wednesday, October 12, 2016 7:50 AM Ruchi Kandoi wrote:
> +/**
> + * struct ion_fd_data - metadata passed from userspace for a handle

s/fd/tag/ ?

> + * @handle:	a handle
> + * @tag: a string describing the buffer
> + *
> + * For ION_IOC_TAG userspace populates the handle field with
> + * the handle returned from ion alloc and type contains the memtrack_type which
> + * accurately describes the usage for the memory.
> + */
> +struct ion_tag_data {
> +	ion_user_handle_t handle;
> +	char tag[ION_MAX_TAG_LEN];
> +};
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
