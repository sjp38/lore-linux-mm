Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65C16C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 12:09:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 305C6206C2
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 12:09:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 305C6206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4D456B0005; Tue, 13 Aug 2019 08:09:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD5316B0006; Tue, 13 Aug 2019 08:09:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9C3F6B0007; Tue, 13 Aug 2019 08:09:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id 802926B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:09:55 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1DA02180AD7C3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:09:55 +0000 (UTC)
X-FDA: 75817285950.27.quilt93_1c55421662f2a
X-HE-Tag: quilt93_1c55421662f2a
X-Filterd-Recvd-Size: 5708
Received: from mail-wm1-f66.google.com (mail-wm1-f66.google.com [209.85.128.66])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:09:54 +0000 (UTC)
Received: by mail-wm1-f66.google.com with SMTP id g67so1245618wme.1
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:09:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=gDECUkDx4MmZTU2TRfkEx9c0GNMHS7ThvPK76SizlZs=;
        b=KJxtOI0XXRz/BpO5dJZ/2HncOfLPAiCNdEXwzDAa4EwIByPWwmi9RpvY+BV4iKWA2g
         3K/SkHloRfRX3cKnCxeJxoPZu2Atc7MPY2XFUY1N2mBWFEetTRvitBauSypI/qHdv2Jt
         GHFWLjLb83I/kWRAIkrZ5YYTg0+1VM0ZfLievqn0lWE/1ldcSQNhUDyaqDfJOQgxZIsf
         wf/pIOIfVXMqOIflwp5rvpGbclNcQPmIJ61UCyXqVfYHHfLVNtSKXtaUbJYKVcaIiCC4
         Gbr+3ExrpnEkUkAt8Ecq/AtNscupl1STXAOGjBj49uLBng7qilFUxEgtNupCZmpfdIae
         9TWg==
X-Gm-Message-State: APjAAAWWxUBIZTAIDz3jlusLYe1ui+vtg1j5giy23MXZftDIxmxJ81FW
	umKT+Bm2LSGqy3rBATSlMjz0zw==
X-Google-Smtp-Source: APXvYqzB612TQbc7of6OKwGZTQDBF2YBSrRWlPNUTz0Jo1N+YWu/anTDovRV4uYtYUMMFIBRr0LWzQ==
X-Received: by 2002:a1c:c00e:: with SMTP id q14mr2852175wmf.142.1565698193218;
        Tue, 13 Aug 2019 05:09:53 -0700 (PDT)
Received: from ?IPv6:2001:b07:6468:f312:5193:b12b:f4df:deb6? ([2001:b07:6468:f312:5193:b12b:f4df:deb6])
        by smtp.gmail.com with ESMTPSA id g26sm1123736wmh.32.2019.08.13.05.09.51
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 05:09:52 -0700 (PDT)
Subject: Re: [RFC PATCH v6 01/92] kvm: introduce KVMI (VM introspection
 subsystem)
To: =?UTF-8?Q?Adalbert_Laz=c4=83r?= <alazar@bitdefender.com>,
 Sean Christopherson <sean.j.christopherson@intel.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
 virtualization@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?=
 <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Tamas K Lengyel <tamas@tklengyel.com>,
 Mathieu Tarral <mathieu.tarral@protonmail.com>,
 =?UTF-8?Q?Samuel_Laur=c3=a9n?= <samuel.lauren@iki.fi>,
 Patrick Colp <patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
 Stefan Hajnoczi <stefanha@redhat.com>,
 Weijiang Yang <weijiang.yang@intel.com>, Zhang@vger.kernel.org,
 Yu C <yu.c.zhang@intel.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?=
 <mdontu@bitdefender.com>, =?UTF-8?Q?Mircea_C=c3=aerjaliu?=
 <mcirjaliu@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-2-alazar@bitdefender.com>
 <20190812202030.GB1437@linux.intel.com>
 <5d52a5ae.1c69fb81.5c260.1573SMTPIN_ADDED_BROKEN@mx.google.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <5fa6bd89-9d02-22cd-24a8-479abaa4f788@redhat.com>
Date: Tue, 13 Aug 2019 14:09:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <5d52a5ae.1c69fb81.5c260.1573SMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13/08/19 13:57, Adalbert Laz=C4=83r wrote:
>> The refcounting approach seems a bit backwards, and AFAICT is driven b=
y
>> implementing unhook via a message, which also seems backwards.  I assu=
me
>> hook and unhook are relatively rare events and not performance critica=
l,
>> so make those the restricted/slow flows, e.g. force userspace to quies=
ce
>> the VM by making unhook() mutually exclusive with every vcpu ioctl() a=
nd
>> maybe anything that takes kvm->lock.=20
>>
>> Then kvmi_ioctl_unhook() can use thread_stop() and kvmi_recv() just ne=
eds
>> to check kthread_should_stop().
>>
>> That way kvmi doesn't need to be refcounted since it's guaranteed to b=
e
>> alive if the pointer is non-null.  Eliminating the refcounting will cl=
ean
>> up a lot of the code by eliminating calls to kvmi_{get,put}(), e.g.
>> wrappers like kvmi_breakpoint_event() just check vcpu->kvmi, or maybe
>> even get dropped altogether.
>=20
> The unhook event has been added to cover the following case: while the
> introspection tool runs in another VM, both VMs, the virtual appliance
> and the introspected VM, could be paused by the user. We needed a way
> to signal this to the introspection tool and give it time to unhook
> (the introspected VM has to run and execute the introspection commands
> during this phase). The receiving threads quits when the socket is clos=
ed
> (by QEMU or by the introspection tool).
>=20
> It's a bit unclear how, but we'll try to get ride of the refcount objec=
t,
> which will remove a lot of code, indeed.

You can keep it for now.  It may become clearer how to fix it after the
event loop is cleaned up.

>>
>>> +void kvmi_create_vm(struct kvm *kvm)
>>> +{
>>> +	init_completion(&kvm->kvmi_completed);
>>> +	complete(&kvm->kvmi_completed);
>> Pretty sure you don't want to be calling complete() here.
> The intention was to stop the hooking ioctl until the VM is
> created. A better name for 'kvmi_completed' would have been
> 'ready_to_be_introspected', as kvmi_hook() will wait for it.
>=20
> We'll see how we can get ride of the completion object.

The ioctls are not accessible while kvm_create_vm runs (only after
kvm_dev_ioctl_create_vm calls fd_install).  Even if it were, however,
you should have placed init_completion much earlier, otherwise
wait_for_completion would access uninitialized memory.

Paolo

