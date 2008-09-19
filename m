Received: by rv-out-0708.google.com with SMTP id f25so540787rvb.26
        for <linux-mm@kvack.org>; Fri, 19 Sep 2008 14:57:04 -0700 (PDT)
Message-ID: <84144f020809191457s447c8c2evbdf784a857c8f44e@mail.gmail.com>
Date: Sat, 20 Sep 2008 00:57:04 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 0/3] Cpu alloc slub support: Replace percpu allocator in slub.c
In-Reply-To: <20080919203703.312007962@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080919203703.312007962@quilx.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 19, 2008 at 11:37 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> Slub also has its own per cpu allocator. Get rid of it and use cpu_alloc().

So, do you want to stick these into the slab tree? I would then need
to pick up the cpualloc patches as well, I suppose. Andrew, pls help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
