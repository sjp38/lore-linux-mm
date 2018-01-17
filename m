Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9E9280298
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 05:45:13 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id i2so11176215pgq.8
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 02:45:13 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s9si4092556plr.684.2018.01.17.02.45.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 02:45:12 -0800 (PST)
Message-ID: <5A5F29C9.4040706@intel.com>
Date: Wed, 17 Jan 2018 18:47:37 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v22 2/3] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
References: <1516165812-3995-1-git-send-email-wei.w.wang@intel.com> <1516165812-3995-3-git-send-email-wei.w.wang@intel.com> <1003745745.1007975.1516177271163.JavaMail.zimbra@redhat.com> <5A5F109B.7090200@intel.com> <1239524301.1023371.1516181271621.JavaMail.zimbra@redhat.com>
In-Reply-To: <1239524301.1023371.1516181271621.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang opensource <liliang.opensource@gmail.com>, yang zhang wz <yang.zhang.wz@gmail.com>, quan xu0 <quan.xu0@gmail.com>, nilal@redhat.com, riel@redhat.com

On 01/17/2018 05:27 PM, Pankaj Gupta wrote:
>> On 01/17/2018 04:21 PM, Pankaj Gupta wrote:
>>
> o.k  you have initialize "err = -ENOMEM;"
>
> Remove these four lines.
>   
>   -        kfree(names);
>   -        kfree(callbacks);
>   -        kfree(vqs);
>   -        return 0;
>
>   +        err = 0;              // if executed without any error
>

OK, thanks. "error = 0" is not needed actually.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
