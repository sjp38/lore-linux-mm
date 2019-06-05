Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BC06C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:07:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1415D206BA
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:07:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FHVBZSYx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1415D206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A3EE6B0007; Wed,  5 Jun 2019 09:07:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 953A66B000A; Wed,  5 Jun 2019 09:07:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8425F6B000D; Wed,  5 Jun 2019 09:07:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 486A96B0007
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 09:07:39 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d19so16073565pls.1
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 06:07:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wOlyBFObbo8NjdwW/6yyuIHGU1UFK5s5OLlA3iBoq+w=;
        b=CqMIiIJpMJNoQqsE8vxD21hSnRQLq6cr8hQF4yn0Rj6etADYPOvOnIdOlOS+t4hBk7
         nT4qlVYWEfSNbw82pkW7okoA6BmgBKkNP2tu4G44sQ4DBSX7mryRqqnGFua+bLs1EINj
         nrskxnWmvCMoxOj/YgTSGK4/i25KS0HT4kPCxBXlDz0e252ogw3qEeCeuETtyebb+7Z/
         mpgssgerO6ThA3FvBLksnbpn1myLqofn7VcW/YEd+IbrqXB13K28nx/5fecMwRauqDN8
         zLkqiZCUaLskeDd1y7XYvXcANJt3xyRBdxh7lmrzUho/Mb7kEhezkX8ZXqDjlaArt8zF
         Kunw==
X-Gm-Message-State: APjAAAWg0F3/3SrLy4wASQzchJo1N7R41EcXvYhzKvN/yQ/14w5fHFMe
	AwJlIbVh3O3eThcEWhGLL1jLI4ML4jwXkDpJ+K4iUl8m1VM6hAGTej+y5UaCoQtz9jBFQGt/RRb
	SzNBPh2khZ7Y61zMvaKNtJvi/Ku+k2XWM1JyMCMtJNHjmDFHqNae/o7HkqUBUmcAEdw==
X-Received: by 2002:a17:902:8f87:: with SMTP id z7mr17656093plo.65.1559740058877;
        Wed, 05 Jun 2019 06:07:38 -0700 (PDT)
X-Received: by 2002:a17:902:8f87:: with SMTP id z7mr17655981plo.65.1559740058008;
        Wed, 05 Jun 2019 06:07:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559740058; cv=none;
        d=google.com; s=arc-20160816;
        b=wp5kguDBvZ3ilHAswbPTdnt3/KDgFr0nVeO5pLlIcm9t+bVVBI/isy4ugreLptOAWE
         PPihdxtnix+yVRBgcOUotXOPD8ID0pfxZk/YfB7OjllwPddK0n7fVnh5i54zCcPVCxZ4
         JNQETEzD3q9bOQBi7te61P0Mwwin6rXaiEQ1kzHBLt35E2CjXP3u9blgc9GoUfvCW4IH
         x4qtz2LbbyMS3IAnn9Q6bg+da6NqkNlu6jpxVQrmnpZX9wzUoPnNo3WvEJozRBK0WsKa
         KKcywARHSE7AJ+NCgBC//jHREjN+RKRYl16Wm3fuf2ALUFapf7Nnt3MqNiCLYD6O18ey
         +Wmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wOlyBFObbo8NjdwW/6yyuIHGU1UFK5s5OLlA3iBoq+w=;
        b=pLRNOzRBytjQGMAEiUt6iD69U/qXHsIzWlg7js5nJHbBqQI6pjNpGPWLkm8b2MMDDO
         z51NWb4HdbdS4uU1nROUMS+okCccy8gHRk2A9H9K02V8uTBJpxKoRqxrJmhTvalirgto
         0WGJWtNM6lXFZjQJYC1Vp6MEB6SfOtw/iVG3spm2uVYkQZ/cpS8dQEV4cG/CicH+qNgp
         2Icv+girh2Paqre8o0aSn4DuPo1YocYkQLnJnMryoQoYPwqxCnd6m5rJiL5EmnfBWFSJ
         zIrGBCYV7IyP/+QUM6LgJTbQDjw/6K4qVLc7g40oCYUusfTWtSuy7SeXMJMPjwWOrkw0
         ByCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FHVBZSYx;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n20sor9261640pff.10.2019.06.05.06.07.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 06:07:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FHVBZSYx;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=wOlyBFObbo8NjdwW/6yyuIHGU1UFK5s5OLlA3iBoq+w=;
        b=FHVBZSYxmRtSJYlqQE0H/b8ZtWCu695UJZ+WO7ngmounpNDd6iuwZjKE421R2ZccPO
         GJZzw1FsL1ZFgnaCVULcC95mrP/8jCJmXao2OHGeJjzAcQa0/VRFu4veT8pbsvd1+R0I
         nAA59AXZVzBTFCNSTeXN07vPh9igCwIq1Bw/AqouS9PsTEdmGdXk0f1pd+wtnWxlIgO8
         ReT7UuJZpNn9QaTMp0IA7ixS7XXrChbH3t0IJUJS1ceTCDqlzwYrYgg7zHeAtA6SKyZ6
         Qe2f62gMzZ2YvjwcITQ6RHJsNNByTelmkp4bV/IHHvokLcAXtkVHL9dsgQ1OcNJ8wf+9
         hKXw==
X-Google-Smtp-Source: APXvYqzZ7bEahJmYv3MKynQwr6920gIAVIlvDpIe1bC9ArADTolL3SDQfZvrSpqhIJfypgBQSAUCrw==
X-Received: by 2002:a62:65c7:: with SMTP id z190mr46027677pfb.73.1559740057712;
        Wed, 05 Jun 2019 06:07:37 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([2401:4900:2716:aaa4:847a:64de:b0a1:1485])
        by smtp.gmail.com with ESMTPSA id d20sm18942088pjs.24.2019.06.05.06.07.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 06:07:37 -0700 (PDT)
Date: Wed, 5 Jun 2019 18:37:28 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org,
	vbabka@suse.cz, rientjes@google.com
Cc: khalid.aziz@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Remove VM_BUG_ON in __alloc_pages_node
Message-ID: <20190605130727.GA25529@bharath12345-Inspiron-5559>
References: <20190605060229.GA9468@bharath12345-Inspiron-5559>
 <20190605070312.GB15685@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605070312.GB15685@dhcp22.suse.cz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Not replying inline as my mail is bouncing back]

This patch is based on reading the code rather than a kernel crash. My
thought process was that if an invalid node id was passed to
__alloc_pages_node, it would be better to add a VM_WARN_ON and fail the
allocation rather than crashing the kernel. 
I feel it would be better to fail the allocation early in the hot path
if an invalid node id is passed. This is irrespective of whether the
VM_[BUG|WARN]_*s are enabled or not. I do not see any checks in the hot
path for the node id, which in turn may cause NODE_DATA(nid) to fail to
get the pglist_data pointer for the node id. 
We can optimise the branch by wrapping it around in unlikely(), if
performance is the issue?
What are your thoughts on this? 

Thank you 
Bharath

