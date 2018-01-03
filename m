Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1FBAE6B02F1
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 22:34:17 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id i189so190620pgc.15
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 19:34:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w16sor39815plk.25.2018.01.02.19.34.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jan 2018 19:34:16 -0800 (PST)
Subject: Re: [RFC PATCH v4 00/18] VM introspection
References: <20171218190642.7790-1-alazar@bitdefender.com>
From: Xiao Guangrong <guangrong.xiao@gmail.com>
Message-ID: <310d60aa-9979-cb73-058d-831ca6b98dfa@gmail.com>
Date: Wed, 3 Jan 2018 11:34:51 +0800
MIME-Version: 1.0
In-Reply-To: <20171218190642.7790-1-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Adalber_Laz=c4=83r?= <alazar@bitdefender.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>



On 12/19/2017 03:06 AM, Adalber LazA?r wrote:
> From: Adalbert Lazar <alazar@bitdefender.com>
> 
> This patch series proposes a VM introspection subsystem for KVM (KVMI).
> 
> The previous RFC can be read here: https://marc.info/?l=kvm&m=150514457912721
> 
> These patches were tested on kvm/master,
> commit 43aabca38aa9668eee3c3c1206207034614c0901 (Merge tag 'kvm-arm-fixes-for-v4.15-2' of git://git.kernel.org/pub/scm/linux/kernel/git/kvmarm/kvmarm into HEAD).
> 
> In this iteration we refactored the code based on the feedback received
> from Paolo and others.

I am thinking if we can define some check points in KVM where
BPF programs are allowed to attach, then employ the policies
in BPFs instead...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
