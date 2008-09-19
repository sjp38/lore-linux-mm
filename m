Received: by wa-out-1112.google.com with SMTP id m28so354544wag.8
        for <linux-mm@kvack.org>; Fri, 19 Sep 2008 08:28:03 -0700 (PDT)
Message-ID: <2f11576a0809190828s4b74ac5y8cd6dd201332fbe2@mail.gmail.com>
Date: Sat, 20 Sep 2008 00:28:02 +0900
From: "KOSAKI Motohiro" <m-kosaki@ceres.dti.ne.jp>
Subject: Re: [patch 0/4] Cpu alloc V5: Replace percpu allocator in modules.c
In-Reply-To: <20080919145859.062069850@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080919145859.062069850@quilx.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

Hi Cristoph,

> Just do the bare mininum to establish a per cpu allocator. Later patchsets
> will gradually build out the functionality.
>
> The most critical issue that came up on the last round is how to configure
> the size of the percpu area. Here we simply use a kernel parameter and use
> the static size of the existing percpu allocator for modules as a default.
>
> The effect of this patchset is to make the size of percpu data for modules
> configurable. Its no longer fixed at 8000 bytes.

I don't know so much this area.
Could you please what are the problem that you think　about?

performance?
fixed-size cause per-cpu starvation by huge user?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
