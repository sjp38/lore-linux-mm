Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC59828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 05:24:39 -0500 (EST)
Received: by mail-qk0-f176.google.com with SMTP id x1so9261339qkc.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 02:24:39 -0800 (PST)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id q143si3923252ywg.258.2016.01.14.02.24.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 02:24:38 -0800 (PST)
Message-ID: <56977759.7080806@citrix.com>
Date: Thu, 14 Jan 2016 10:24:25 +0000
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/2] xen_balloon: support memory auto onlining policy
References: <1452706350-21158-1-git-send-email-vkuznets@redhat.com>
 <1452706350-21158-3-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1452706350-21158-3-git-send-email-vkuznets@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org
Cc: Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan
 Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

On 13/01/16 17:32, Vitaly Kuznetsov wrote:
> Add support for the newly added kernel memory auto onlining policy to Xen
> ballon driver.

Acked-by: David Vrabel <david.vrabel@citrix.com>

Thanks.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
