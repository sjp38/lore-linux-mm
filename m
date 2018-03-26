Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 093F16B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 17:24:04 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e19so10066348pga.1
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 14:24:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t2-v6si15225627plm.3.2018.03.26.14.24.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 14:24:03 -0700 (PDT)
Date: Mon, 26 Mar 2018 14:24:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v29 3/4] mm/page_poison: expose page_poisoning_enabled
 to kernel modules
Message-Id: <20180326142400.82c7f29992c4b0c3a8f4d230@linux-foundation.org>
In-Reply-To: <1522031994-7246-4-git-send-email-wei.w.wang@intel.com>
References: <1522031994-7246-1-git-send-email-wei.w.wang@intel.com>
	<1522031994-7246-4-git-send-email-wei.w.wang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

On Mon, 26 Mar 2018 10:39:53 +0800 Wei Wang <wei.w.wang@intel.com> wrote:

> In some usages, e.g. virtio-balloon, a kernel module needs to know if
> page poisoning is in use. This patch exposes the page_poisoning_enabled
> function to kernel modules.

Acked-by: Andrew Morton <akpm@linux-foundation.org>
