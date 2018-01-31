Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 16B5C6B0009
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 12:48:44 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id l17so2906106otf.12
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 09:48:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b187si7963747oih.542.2018.01.31.09.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 09:48:43 -0800 (PST)
Date: Wed, 31 Jan 2018 12:48:40 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] Killing reliance on struct page->mapping
Message-ID: <20180131174840.GF2912@redhat.com>
References: <20180130004347.GD4526@redhat.com>
 <111f49c1-02d1-3355-e403-a8f91c0191e2@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <111f49c1-02d1-3355-e403-a8f91c0191e2@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Wed, Jan 31, 2018 at 07:09:48PM +0200, Igor Stoppa wrote:
> On 30/01/18 02:43, Jerome Glisse wrote:
> 
> [...]
> 
> > Maybe we can kill page->mapping altogether as a result of this. However this is
> > not my motivation at this time.
> 
> We had a discussion some time ago
> 
> http://www.openwall.com/lists/kernel-hardening/2017/07/07/7
> 
> where you advised to use it for tracking pmalloc pages vs area, which
> generated this patch:
> 
> http://www.openwall.com/lists/kernel-hardening/2018/01/24/7
> 
> Could you please comment what wold happen to the shortcut from struct
> page to vm_struct that this patch is now introducing?

Sadly struct page fields means different thing depending on the context
in which the page is use. This is confusing i know. So when i say kill
page->mapping i am not saying shrink the struct page and remove that
field, i am saying maybe we can kill current user of page->mapping
for regular process page (ie page that are in some mmap() area of a
process).

Other use of that field in different context like yours are not affected
by this change and can ignore it alltogether.

Hope this clarify it :)

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
