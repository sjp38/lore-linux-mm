Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C61DBC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 17:50:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C1C320881
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 17:50:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C1C320881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A5E68E0002; Mon, 28 Jan 2019 12:50:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 155BF8E0001; Mon, 28 Jan 2019 12:50:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 046518E0002; Mon, 28 Jan 2019 12:50:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B97878E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:50:57 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id b24so12254051pls.11
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:50:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tiKrXRWXcQKuiQfu4b4nOKmW+HrB+aDLZqiEfbD/xpY=;
        b=eynZcaEAZN7NRkDjG9j8kBdQ0DgtghQtIZYZlERWN/xewPZrCn0mhI96O7X2D1Up92
         Khh40cl0cZKPRILom5ikeXWlbGOe2p7F/wbx/5A7KLeoRt7VispyaOHcnOy92kWQUDuq
         TcKlmH7iKBShKQlBXGSU07fJZBS1W++eSikzLQ+t0Z1l45a4PkqNbvYr8weRbcaxDFng
         GuS1HZJwBtjktusVG7nDr4wIXrvTf1hWf/B1l4cK/5lw4DdiepMwUauQDr8F0XKOIgVy
         62CMd9zR0KMqLpA18pg9vWVKXBcgL90/Em0BcKoBYtbUJJ5X4KGgvr0nfTTOfswbuOnU
         jsNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukeH/ihtZSG8tpqB9pIIjJHSNqSUrLr/IQpT3CfoYmpQyWC7fBX4
	pg1hZeizMAOnK8KfNmrNBjIFaKIQ9QScYrRjzsPBJANKTN0HeyppfGQPpQje+VmQyHWUbdiSe3P
	WmCtYFeDPsHpcuO+bn3uYq7NqKw9zFawnuRvvqs9DeiRdEzErte+YlYM9InJacIgDDQ==
X-Received: by 2002:a17:902:a70b:: with SMTP id w11mr22535512plq.84.1548697857366;
        Mon, 28 Jan 2019 09:50:57 -0800 (PST)
X-Google-Smtp-Source: ALg8bN517Q4NuYyovx7Z1O6OmNcYp1iTj3kA8lXGWVOH2BcUDpmdGN0IUuxCbEABRHpAjDjVxNgi
X-Received: by 2002:a17:902:a70b:: with SMTP id w11mr22535479plq.84.1548697856381;
        Mon, 28 Jan 2019 09:50:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548697856; cv=none;
        d=google.com; s=arc-20160816;
        b=WBMaa4qASzZpBpxETT4ndJ9NItuhKDwLnd5uwYH5HBK6dW8mPTD5ZNZgF/xdPB6mEp
         GtKXEN/mxONT1QVWcb0HGzA9zrbctbgSTLv7wIwDIOI1BbDmone7SZaSNCXUj+8hLEe5
         NVVW1Rk+vSHXUXeUOd1tPZV4VjLn/0wzNfxNINF4UnNoRgB77hRYn0gXuyu77g+J6EWl
         YaO1SCKaSPHQGknKcT/HNuiFFBk6a7MVlMfQJ/M5R9ksbgYmH1lLBJeHndGzhMhWv9wo
         EF8WwHkBkpFvA3Xy0eFw4Ue/adGz5T8DX8mk9udyhikbCKdqv/SMaBa0W83g4pSpYkLG
         9l/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=tiKrXRWXcQKuiQfu4b4nOKmW+HrB+aDLZqiEfbD/xpY=;
        b=K01SZ4Yn1j8HyqFsls5LkEtfPZjNLjne39eZgiJFHJqiOPnj5NqRi6pW0xAnGRYrvz
         D5wAbDwgLHF5BI4hBV4AewqZ6Ma9Y3x74yDlcDd3a+IOVbjyDC22U74D7/H5o55Gq0OO
         7Iyl0wniRxIaNaUZ2gIeMfLzIN+xXIq8kzBdCuwixqVFKZqaEP5K0/ZRrEyYSedDkJHK
         qeB6wwXlJvIYOSzTLVyCk985Qa7UgARNFTNG46PGl7EHPXFL+8OyQScogpZDn9Ps3s/+
         YlOE4W3dyTTBGx3AWeqr20GmXNuIQb99TKcL8fe0I4Br0A3xXbVTXwZazzgKpjKayFo5
         2njA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 28si26380103pgz.593.2019.01.28.09.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 09:50:56 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id D08CF2541;
	Mon, 28 Jan 2019 17:50:55 +0000 (UTC)
Date: Mon, 28 Jan 2019 09:50:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>, Mikhail Gavrilov
 <mikhail.v.gavrilov@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
 gerald.schaefer@de.ibm.com, <linux-mm@kvack.org>, LKML
 <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/2] mm, memory_hotplug: fix uninitialized pages
 fallouts.
Message-Id: <20190128095054.4103093dec81f1c904df7929@linux-foundation.org>
In-Reply-To: <20190128144506.15603-1-mhocko@kernel.org>
References: <20190128144506.15603-1-mhocko@kernel.org>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128175054.1G-oldxo1UIxrn3Ca_oCdLnf2B_xIqL_c8V7xpSYNsk@z>

On Mon, 28 Jan 2019 15:45:04 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> Mikhail has posted fixes for the two bugs quite some time ago [1]. I
> have pushed back on those fixes because I believed that it is much
> better to plug the problem at the initialization time rather than play
> whack-a-mole all over the hotplug code and find all the places which
> expect the full memory section to be initialized. We have ended up with
> 2830bf6f05fb ("mm, memory_hotplug: initialize struct pages for the full
> memory section") merged and cause a regression [2][3]. The reason is
> that there might be memory layouts when two NUMA nodes share the same
> memory section so the merged fix is simply incorrect.
> 
> In order to plug this hole we really have to be zone range aware in
> those handlers. I have split up the original patch into two. One is
> unchanged (patch 2) and I took a different approach for `removable'
> crash. It would be great if Mikhail could test it still works for his
> memory layout.
> 
> [1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
> [2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
> [3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz

Any thoughts on which kernel version(s) need these patches?

