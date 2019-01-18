Return-Path: <SRS0=AIe5=P2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACE8BC43387
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 11:21:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7344A2086D
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 11:21:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7344A2086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E1AE8E0004; Fri, 18 Jan 2019 06:21:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06AFB8E0002; Fri, 18 Jan 2019 06:21:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4E918E0004; Fri, 18 Jan 2019 06:21:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id B65B58E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 06:21:50 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id v199so5619495vsc.21
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 03:21:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=7aUBFwh51WxLFPqE3odQpSNMqOAQG8K9rCeVIuJbP10=;
        b=W8jp7u+/lJtB9xebzOWGiiajBxagFiomfKy1cv0vyq7AahCZ/DSM9i3uZIDhosvA12
         fubNtkgJ2wYCtFHBa73vLuRufibj3g12QfEWJXvvgXTnK8SXo86emP5CaTuUs3XgrleQ
         nX0oFs/rhqfKm4d81UsQYT0mNlqUFzWMsUYn7K1HX+hZ1kEwEQQasetd6td7W/mgJfIf
         h2k3q2BNUWKf4zjzvKMA9sI+avtN3rAKwgqaHl7HSi/bVd27gDkj5IrtNTDHRbwmA8KD
         jNwBorgTs4scfRUoP2MCLCTEIkkq2tTUd3AjcmdXQ1JSCYDm0X8hHcGP1gOlQU2m+5Ja
         5SnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AJcUukcCWnMnAZg2UWuYPHdCV+bXq4mwlM2UJAwSksH42NpTfTupHFb6
	20fzAETj0Hku4K2gDRc4EHQa6HYYe7zg7i97ZH5iUX9pqrwXAsbJaY37E8quiItzYEFPHozLShV
	TnWNzAVYVqzfLkudiX3+porbowxguXcCazX57OTzrVpeh0tyZ2xB3oocZ+Bs0/zMowg==
X-Received: by 2002:a05:6102:391:: with SMTP id m17mr7680243vsq.100.1547810510484;
        Fri, 18 Jan 2019 03:21:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4BoEsDVFvv+pkHcqLREloJgc5qVRP3Xnl8JJxv1eShqoLc5hn5tulgbBRrWLrgaM+eobQp
X-Received: by 2002:a05:6102:391:: with SMTP id m17mr7680226vsq.100.1547810509822;
        Fri, 18 Jan 2019 03:21:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547810509; cv=none;
        d=google.com; s=arc-20160816;
        b=bVMut+rTqCAAys+3VSeWZtAMAf8/5mkOG3BxoahVNncG0YoMQP/imi+hiXeZO89oo5
         lK9zbD9NFwUbiwsC+wnPrUr2d1KO12s4OESBn+lV/W74pm+W7C8f/wR0AbemAe5sd3fn
         oybj3KT96Fyl5HHpU9Ux1tOUowSA97pKDEAhLMOtUzZe/OXIskWpVv4k6LpfANCBoYuA
         PfTgYVUbSykRSbJXxMxp9a9ECmyRhUKJGtMngH7EDE7d4QCCSN4al91dlVueH5ZTW3Ny
         K7DV/L3U5tdRtDDCI2Iyuk8Rk1nE7FKD6nW305S/RGqxP4YatJdKQbIsgExy+T4LW9c9
         Zovw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=7aUBFwh51WxLFPqE3odQpSNMqOAQG8K9rCeVIuJbP10=;
        b=dmXDtUYsrxxenTWRUn7RUa1dCbhgTCEoBfzXo1b1eSJU7/v4OF6kYf9wLMBT05jnw+
         z/l/jWAkJWAMyoWNjj1jJ36ZiB+oBh2rVsja56gBQyyVk+xqGMfgoFmgE4nD+jt8upTY
         AQZXgju1xbN0psS6MIgBXg7N6KGWQJRWhrlx2kiALclfOn4ui8O9xq7SfBeveOJomq7K
         jdiVzsTQ6r0FBe70NijNxwTpq4pObgAhJyYxk/eZw1mx6tcED+OjNRvX4dBqVplIbWAW
         qPP9eDkk/RON6hYedfhl38PBORYik/iLb6QO1K6/7+/C2bfBTDq3ca8TGTbZdJh6C6sv
         gjFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id s4si2453078uao.54.2019.01.18.03.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 03:21:49 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id E0E2764CB6599412032A;
	Fri, 18 Jan 2019 19:21:45 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS403-HUB.china.huawei.com
 (10.3.19.203) with Microsoft SMTP Server id 14.3.408.0; Fri, 18 Jan 2019
 19:21:44 +0800
Date: Fri, 18 Jan 2019 11:21:34 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	"Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs
 attributes
Message-ID: <20190118112134.00003b65@huawei.com>
In-Reply-To: <20190116175804.30196-6-keith.busch@intel.com>
References: <20190116175804.30196-1-keith.busch@intel.com>
	<20190116175804.30196-6-keith.busch@intel.com>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190118112134.YuftfxjvRgw2ssXmtgcOCZz84VcRI-a7BrwiZaYL0O0@z>

On Wed, 16 Jan 2019 10:57:56 -0700
Keith Busch <keith.busch@intel.com> wrote:

> Add entries for memory initiator and target node class attributes.
> 
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  Documentation/ABI/stable/sysfs-devices-node | 25 ++++++++++++++++++++++++-
>  1 file changed, 24 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 3e90e1f3bf0a..a9c47b4b0eee 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -90,4 +90,27 @@ Date:		December 2009
>  Contact:	Lee Schermerhorn <lee.schermerhorn@hp.com>
>  Description:
>  		The node's huge page size control/query attributes.
> -		See Documentation/admin-guide/mm/hugetlbpage.rst
> \ No newline at end of file
> +		See Documentation/admin-guide/mm/hugetlbpage.rst
> +
> +What:		/sys/devices/system/node/nodeX/classY/
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The node's relationship to other nodes for access class "Y".
> +
> +What:		/sys/devices/system/node/nodeX/classY/initiator_nodelist
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The node list of memory initiators that have class "Y" access
> +		to this node's memory. CPUs and other memory initiators in
> +		nodes not in the list accessing this node's memory may have
> +		different performance.
> +
> +What:		/sys/devices/system/node/nodeX/classY/target_nodelist
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The node list of memory targets that this initiator node has
> +		class "Y" access. Memory accesses from this node to nodes not
> +		in this list may have differet performance.

Different performance from what?  In the other thread we established that
these target_nodelists are kind of a backwards reference, they all have
their characteristics anyway.  Perhaps this just needs to say:
"Memory access from this node to these targets may have different performance"?

i.e. Don't make the assumption I did that they should all be the same!



