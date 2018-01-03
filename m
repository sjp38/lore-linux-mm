Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 449356B0369
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 13:52:14 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id k44so1243912wre.1
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 10:52:14 -0800 (PST)
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id r16si1191273wrc.91.2018.01.03.10.52.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 10:52:12 -0800 (PST)
Received: from smtp03.buh.bitdefender.org (smtp.bitdefender.biz [10.17.80.77])
	by mx-sr.buh.bitdefender.com (Postfix) with ESMTP id 450327FC09
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 20:52:11 +0200 (EET)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v4 00/18] VM introspection
In-Reply-To: <20171218190642.7790-1-alazar@bitdefender.com>
References: <20171218190642.7790-1-alazar@bitdefender.com>
Date: Wed, 03 Jan 2018 20:52:40 +0200
Message-ID: <1515005560.Ec1edBDC.26237@host>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@gmail.com>, Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>, Patrick Colp <patrick.colp@oracle.com>

On Mon, 18 Dec 2017 21:06:24 +0200, Adalber LazA?r <alazar@bitdefender.com> wrote:
> This patch series proposes a VM introspection subsystem for KVM (KVMI).

...

> We hope to make public our repositories (kernel, QEMU,
> userland/simple-introspector) in a couple of days ...

Thanks to Mathieu Tarral, these patches (updated with the Patrick's
suggestions) can be found in the kvmi branch of the KVM-VMI project[1].
There is also a userland library and a simple demo/test program
in tools/kvm/kvmi[2]. The QEMU patch has its own kvmi[3] branch/repo.

[1]: https://github.com/KVM-VMI/kvm/tree/kvmi
[2]: https://github.com/KVM-VMI/kvm/tree/kvmi/tools/kvm/kvmi
[3]: https://github.com/KVM-VMI/qemu/tree/kvmi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
