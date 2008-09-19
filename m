Message-ID: <48D3CA40.3090807@linux-foundation.org>
Date: Fri, 19 Sep 2008 10:50:24 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch 0/4] Cpu alloc V5: Replace percpu allocator in modules.c
References: <20080919145859.062069850@quilx.com> <2f11576a0809190828s4b74ac5y8cd6dd201332fbe2@mail.gmail.com>
In-Reply-To: <2f11576a0809190828s4b74ac5y8cd6dd201332fbe2@mail.gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> 
> I don't know so much this area.
> Could you please what are the problem that you think　about?

F.e. Someone is loading lots of modules with lots of percpu data. This will
currently fail if there are more than 8000 bytes allocated. With the percpu
option the size can be configured on bootup. A minor thing but the allocator
can later be used for other things. See the full cpu alloc patchsets that have
been posted before (last one in May).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
