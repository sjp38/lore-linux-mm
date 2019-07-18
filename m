Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DBF1C76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:28:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EE5C21019
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:28:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EE5C21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B923F6B0007; Thu, 18 Jul 2019 16:28:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B42B48E0003; Thu, 18 Jul 2019 16:28:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A30958E0001; Thu, 18 Jul 2019 16:28:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 827F56B0007
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 16:28:15 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id p196so13019796vke.17
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:28:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=B3D519saV0IY04hwLwSMWExcabGqmr2ZPbFB5vbgjIY=;
        b=V1dMRXM8UgR2z77rlox6toLVyaTsJfFBw8bLMhx6rkGjNUtf/+MozWFzMV5gP+kAh3
         102k1q60+pIoF02nuLaU0slBmdVqUzljH8HNKGKmCyhF69JTz1fZqgTaAwrKIBOMDw1V
         gTM9vGbN3VP61sMcj63WliYtkekPKGVtp4PatH4iWeWRm0gjg4wnkTC8OQYtki+dU9yz
         /s0TFnJZppA1UpQOOyR3OHNfkC+gNiM71yENCBEx08CkY5rC50NLvugKvUEGrUTjGJ9u
         Z46DnfBJG7Z7BUPh34u3zfnOZ1FBXpnPyxxQ4bmCe1a1opdcBxKMf5wkVsYUpKJTdGDn
         hMNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXb0O3KtQg1J2lezqx76U7I0yo4nXmjONGT68tNlvU9N115XXWh
	Ryv/Jzk9BGYljAfXz1GKaTJhKfeqt8jTaLm2s6A5A41a0t+zmmGTJsTVsJpYr2stuK8ka2yS3qu
	e8sSuPxkG6QhCNslXBDL76AQYOxH26oyZJGy0s7m98uIaRqmutS4xhS4322k5pL1vZg==
X-Received: by 2002:a67:ff0b:: with SMTP id v11mr29762854vsp.14.1563481695230;
        Thu, 18 Jul 2019 13:28:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvgrDSmB7AQYIyh57H6Wz52iVzDJ4yCoj56fhBuulB8fs017UVrv5+r2s5SV/6TB6t1+zj
X-Received: by 2002:a67:ff0b:: with SMTP id v11mr29762793vsp.14.1563481694662;
        Thu, 18 Jul 2019 13:28:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563481694; cv=none;
        d=google.com; s=arc-20160816;
        b=coWxbzUvI0i3+avXK8IxT4Wh0KH8pZtL8MXSsvpHQ18a+MjgY5Cp4n3BiSV2clhqyY
         ZhUrCRKbn7tHcYYGOJj9B8p506PFEYI9mumMifWg9ZgrM4S9lTHwN4G0UdDPezLt43Y7
         0IWavI43lM2DAvGYW2OgVPE2cmj0srEX8tfvca56spD460uLSq9LhgmFWFMv1fZ4oP3I
         mDOs7biR/tcN/8TzS34Cd44WyuXrbpu7COm84pjmkPbloXSgdteNIV0JPmKJ8EYoYo2x
         QFcVR01Fv4pV8cboQSDFz7THbheRGcsbOqyOKvWZRnh19x4ywZdZKT/YZm6vt9J+MI/N
         V9dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=B3D519saV0IY04hwLwSMWExcabGqmr2ZPbFB5vbgjIY=;
        b=moD+BW7qBW26j9T9LWArnD9cetZ6EpkKhPKd9TtQi7B/+ny5gB87aYlNw8op5Mx9pK
         gaHgVk8jOzs9EuG8+iStv7ACzCPZ3CWP/IgY80yR8BHxtrjT2QnxkG/sr1YR2G3/c2Dt
         2EUcNNLMgJb+junCX6s/nxaqtT3Fdr2iV36TZKwbxADUxQRuLEpcwplFF/6KhfRlTXLh
         ENafMsqiwOMEWu3TlQGEPfcr+y8IbhCRcl499rFjbWL/tCCiF8wjC8ASJyphPgkX4kHM
         nSTyvsqww+2Pd79/YCeHVWQdMm/PHBOCJqEl+G0jryN+aD2k8BW1tKCIrf4PLIBb+uD+
         ohuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a25si4904717uaq.15.2019.07.18.13.28.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 13:28:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B13D4C060201;
	Thu, 18 Jul 2019 20:28:13 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id 9E80D5D71C;
	Thu, 18 Jul 2019 20:27:56 +0000 (UTC)
Date: Thu, 18 Jul 2019 16:27:55 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	kvm list <kvm@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	Dave Hansen <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
	Rik van Riel <riel@surriel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	lcapitulino@redhat.com, wei.w.wang@intel.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
Message-ID: <20190718162502-mutt-send-email-mst@kernel.org>
References: <CAKgT0Uc-2k9o7pjtf-GFAgr83c7RM-RTJ8-OrEzFv92uz+MTDw@mail.gmail.com>
 <20190716115535-mutt-send-email-mst@kernel.org>
 <CAKgT0Ud47-cWu9VnAAD_Q2Fjia5gaWCz_L9HUF6PBhbugv6tCQ@mail.gmail.com>
 <20190716125845-mutt-send-email-mst@kernel.org>
 <CAKgT0UfgPdU1H5ZZ7GL7E=_oZNTzTwZN60Q-+2keBxDgQYODfg@mail.gmail.com>
 <20190717055804-mutt-send-email-mst@kernel.org>
 <CAKgT0Uf4iJxEx+3q_Vo9L1QPuv9PhZUv1=M9UCsn6_qs7rG4aw@mail.gmail.com>
 <20190718003211-mutt-send-email-mst@kernel.org>
 <CAKgT0UfQ3dtfjjm8wnNxX1+Azav6ws9zemH6KYc7RuyvyFo3fQ@mail.gmail.com>
 <ef01c4af-b132-4bed-b1df-0338512caacd@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ef01c4af-b132-4bed-b1df-0338512caacd@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 18 Jul 2019 20:28:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 12:03:23PM -0400, Nitesh Narayan Lal wrote:
> >>>> For example we allocate pages until shrinker kicks in.
> >>>> Fair enough but in fact many it would be better to
> >>>> do the reverse: trigger shrinker and then send as many
> >>>> free pages as we can to host.
> >>> I'm not sure I understand this last part.
> >> Oh basically what I am saying is this: one of the reasons to use page
> >> hinting is when host is short on memory.  In that case, why don't we use
> >> shrinker to ask kernel drivers to free up memory? Any memory freed could
> >> then be reported to host.
> > Didn't the balloon driver already have a feature like that where it
> > could start shrinking memory if the host was under memory pressure?
> If you are referring to auto-ballooning (I don't think it is merged). It
> has its own set of disadvantages such as it could easily lead to OOM,
> memory corruption and so on.

Right. So what I am saying is: we could have a flag that triggers a
shrinker once before sending memory hints.
Worth considering.

-- 
MST

