Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0886D6B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 11:02:28 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id y195so2043687oia.22
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 08:02:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q34si1317549otq.377.2017.12.22.08.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 08:02:26 -0800 (PST)
Subject: Re: [RFC PATCH v4 08/18] kvm: add the VM introspection subsystem
References: <20171218190642.7790-1-alazar@bitdefender.com>
 <20171218190642.7790-9-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <533d5a75-1ac7-4cd4-347d-237a3c9a54c5@redhat.com>
Date: Fri, 22 Dec 2017 17:02:22 +0100
MIME-Version: 1.0
In-Reply-To: <20171218190642.7790-9-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Adalber_Laz=c4=83r?= <alazar@bitdefender.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>, =?UTF-8?B?TmljdciZb3IgQ8OuyJt1?= <ncitu@bitdefender.com>, =?UTF-8?Q?Mircea_C=c3=aerjaliu?= <mcirjaliu@bitdefender.com>, Marian Rotariu <mrotariu@bitdefender.com>

On 18/12/2017 20:06, Adalber LazA?r wrote:
> +	/* VMAs will be modified */
> +	down_write(&req_mm->mmap_sem);
> +	down_write(&map_mm->mmap_sem);
> +

Is there a locking rule when locking multiple mmap_sems at the same
time?  As it's written, this can cause deadlocks.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
