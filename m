Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5572C10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:53:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72564218E2
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:53:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72564218E2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0055D8E0003; Tue, 26 Feb 2019 18:53:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECE328E0001; Tue, 26 Feb 2019 18:53:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D99498E0003; Tue, 26 Feb 2019 18:53:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A085B8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 18:53:27 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id x5so5842415plv.17
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 15:53:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EcEeQ8K4UA9LIZ2bC9HR/jnygqqpzWQf/CfsasDlHUM=;
        b=LCBMPDrJpXaqSYE5RGZtPFjkvgCJh/SserTP7U0n7z/RQQAiKadL+ynbW+UGtgn+V9
         BMI1DJwOJUwKP3T7S+C9UuqsrB1gOBkpsuNQHIN0gd6/Xj5TbPe/4LmxbCFGn8DxtNLX
         1h3H2JntsmsMCE6D9BB6EFYOn8NGmZJ29yAvVuw/GfFhYCNsaNcyiEijHy6MX/ShfZWA
         d78d9C73X0f7So0h1zI6hvcXykaN8A0eEfejM1g/ggO6zj0Y23G0Bjv6IVUx+0vXpvMU
         lTNnNnFrWEWY+jZMhuLWvzxLzBB5DAKVPA6L5UMEYB3JVReNywDNmaurh3ePOHgvnGhJ
         gzig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAubEVegYHUQ9DHJSeUDNeCSulCLVGcgQWLEVGhspPG7tzJhZsC4z
	vaVpfxDYv5cNmVI4gr4yiZdBklIGicKBQ4rpCrC5kCkuuKvn9IemJN4qV/7dAv9SIRnU/M8Qjo7
	J5I52eAm/bSU3ceL+7QXdnhaNGXSs0Yn2f6pyO/MqAvkVUM7i/O8JRK3LyLuj46iklw==
X-Received: by 2002:a17:902:9304:: with SMTP id bc4mr29381499plb.81.1551225207302;
        Tue, 26 Feb 2019 15:53:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbkWOSQQ4VBvyOrIjgO51XuzNx1bkXJYEitkOsQ1jt9bXY+gS0BLae9MTBSa6dtZS2yqWJA
X-Received: by 2002:a17:902:9304:: with SMTP id bc4mr29381442plb.81.1551225206504;
        Tue, 26 Feb 2019 15:53:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551225206; cv=none;
        d=google.com; s=arc-20160816;
        b=eIeTAdJ/Lk8auzi3Fk4xQ0C5qy7WYbtkz6IsJAp5J12a+gkcUG213+8hKM0/cnPEBf
         7LaFtNmN1C5UwDU+Hvna3uKErFsibbJCSRZ4WqSAVd5TOUZjH+FqGKggksTgna63D75h
         tWHkofCooXsZhfffdbULCDJWrDqVUvhMcv1cet250RsX0E7heb2vz4IIOOMmQCsNHvzk
         Xri4sv2NNJ7loJ0kAT+Nd5Pgug7xDIZtUVwV8TpUvQzQq3jy+eONTeQeEn5d+v7tWxPI
         QCkEbiFRFl1T1dUwM+fWhKujVV1EzOClbCCdo3XL5JYFt/I8P5AjwXK3E3Zv5IJxpbYF
         j7XQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=EcEeQ8K4UA9LIZ2bC9HR/jnygqqpzWQf/CfsasDlHUM=;
        b=E6Kdj9GhC2QifdBxOadgkb4lgPzDQhkmean5uSzlBrlTyHlKjSy3dRGvfDS348ZJUM
         ObPdG3fwO8999sH3eRbmrBSZYcVE++hFdrittNlcFJR70bueOnq7s4K7aOuwIJRYAm3i
         7u0q+iGIFvrOMt3CblPnXSCA6u9BM+566jtOp+WSbGkJ4EGYRtu2MPZBBB4xji2bh8Nt
         kEcEBJZTlBKEV1LwRdP06XuNmKVDv8szy0VPJxJ90IfY0GJd5ygdp8QITvyWqLl2w1rb
         lcsZ0uoYqiVrVTY7BRuCNQoHLd7fSQNLGwZWjChK/h/2Pp1dJQghTIQMNH9INEgVcthp
         cBgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g21si13632234pgi.448.2019.02.26.15.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 15:53:26 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id B6C078338;
	Tue, 26 Feb 2019 23:53:25 +0000 (UTC)
Date: Tue, 26 Feb 2019 15:53:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>,
 David Gibson <david@gibson.dropbear.id.au>, Andrea Arcangeli
 <aarcange@redhat.com>, mpe@ellerman.id.au, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH V7 0/4] mm/kvm/vfio/ppc64: Migrate compound pages out of
 CMA region
Message-Id: <20190226155324.e99d5200cc6293138ac5c6fa@linux-foundation.org>
In-Reply-To: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com>
References: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[patch 1/4]: OK.  I guess.  Was this worth consuming our last PF_ flag?
[patch 2/4]: unreviewed
[patch 3/4]: unreviewed, mpe still unhappy, I expect?
[patch 4/4]: unreviewed

