Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CD21C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:22:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D51D9218D3
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:22:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D51D9218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.ee
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7362E6B0003; Thu, 21 Mar 2019 16:22:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70CBF6B0006; Thu, 21 Mar 2019 16:22:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 624CD6B0007; Thu, 21 Mar 2019 16:22:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 15FA36B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:22:47 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id 27so216796ljs.5
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:22:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:from
         :subject:message-id:date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=VwP6/tWBK/DSOOSP/UwHjYGz9NlJvuJ0vIH9+HfczUc=;
        b=OaP63+t/hNkdffmXm/tl1413FfSoxTRQ3GJLPDTGe6+3zHqGrZKlsTLNXwG+gFe0mt
         gac7VjjUvhbMxQJmAB/cQobToh35LWYbCLTz7ZEtp7U8I615gSyXNdAcLFC5NdEPB/8C
         vRnH74ASpjv8LpqY1Sf/cFUJnkPR86fkQ/U8Tbdlnpgj5ym61/z8/RWJe3V4aZ1hSp+z
         YoD3DE0dHcNJwAQdz4N+K50zznlzPmzJIg5c5JnRdkMtMBJyP4BAAbSeSzHGA4MBDeTU
         hTfOrpn2NLRPJKg9f6mxYkYYcZEeJcIx3qIUTwQdlHTax/25ZpLYkb75u5JPYGbWsTVz
         TzTA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
X-Gm-Message-State: APjAAAVK591G98OvmbQU0u9MMK98Y/qj54Dg9lihOZ7HNEE2cFjVkSSO
	ulilDK1F/nWVBYz9SWSDnLm8d2ajoHG9r4jUM3pPjcZ+jbP8zne59Jj3HGQrLFQMuADwuBwd0ik
	B+raDwo/tQWk56iDWKBlOPArYTkuvTheOJ2tnz7nNCUDLrOAW3WdGQzZUw7OyDLs=
X-Received: by 2002:a2e:4b02:: with SMTP id y2mr3093509lja.179.1553199766396;
        Thu, 21 Mar 2019 13:22:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIhPgwrnhxq57flfwXX2AG4KSjAH4uAvDmFalQFYxRDkMATP1nTXeQo3ditHqFNOf0YlvZ
X-Received: by 2002:a2e:4b02:: with SMTP id y2mr3093480lja.179.1553199765542;
        Thu, 21 Mar 2019 13:22:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553199765; cv=none;
        d=google.com; s=arc-20160816;
        b=TTN4MalwGzaNcQYhVDF3hANMrTswkp/XK5P4EepoZCeIWnwVhM+7CpmFg1kXJFfoBv
         ram0isgTTh1k5aiScMoX7TL6ohpUK05CGMFeorOLqMWo/FXkjusw1QKs+u//pGwDkF1y
         wD2ocjTIC7t3h5svtF5yc7x4ZG3XiA9R6j9c6y11LkyQ9vSk6l/iF8xmqAPpr0nlSLvv
         QiT0B/no9WNlgRAfed0pGC6+CrgrTqfRHnOJ9qzvyMFq9+tf1R5cv4wOYGTzq36aWKEU
         OfT0fGoJIhHFPq9nJAWYblBiv67TrzBksXXHATkeyBDyywptcZnMhRpiaV42eFodIrXB
         BPFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:from:to;
        bh=VwP6/tWBK/DSOOSP/UwHjYGz9NlJvuJ0vIH9+HfczUc=;
        b=wno9SBbB3f7XDSqL+OT8fyq+J2toQfrQZsLYt5nUTfXo+Ej4rCttozHfvQivXJ1IRJ
         oyfX17GzWKrpJ4Mps7dcSyp0n2NGTWWlZaW1GjRE9G4Hk5zFsoZ5rYCt8Tk/OhkG+nyV
         fXTw+6rCtUslDiSSzL+Ef+QUHutH7PD4QpBT9p0g+QbyFm5fBdqDMLEwhxvyKD6GaK6H
         F112wEG+E4eeAwGp6ZI5450/mjruVt6GtM47emFxxLGXPGIyQJ/urpanfwG5BpyFI1Oy
         zIC0d1r7yObGH24cMgI9rWThdUnl7yvmU9b7rIPAEE8DngrS4Xq4u4Lm+ZpG9g9Uz4Qh
         t7wg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Received: from mx2.cyber.ee (mx2.cyber.ee. [193.40.6.72])
        by mx.google.com with ESMTPS id u10si4075564lfe.30.2019.03.21.13.22.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 13:22:45 -0700 (PDT)
Received-SPF: neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) client-ip=193.40.6.72;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
From: Meelis Roos <mroos@linux.ee>
Subject: CONFIG_DEBUG_VIRTUAL breaks boot on x86-32
Message-ID: <4d5ee3b0-6d47-a8df-a6b3-54b0fba66ed7@linux.ee>
Date: Thu, 21 Mar 2019 22:22:43 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: et-EE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I tried to debug another problem and turned on most debug options for memory.
The resulting kernel failed to boot.

Bisecting the configurations led to CONFIG_DEBUG_VIRTUAL - if I turned it on
in addition to some other debug options, the machine crashed with

kernel BUG at arch/x86/mm/physaddr.c:79!

Screenshot at http://kodu.ut.ee/~mroos/debug_virtual-boot-hang-1.jpg

The machine was Athlon XP with VIA KT600 chipset and 2G RAM.

-- 
Meelis Roos <mroos@linux.ee>

