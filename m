From: Marcelo Jimenez <mroberto@cpti.cetuc.puc-rio.br>
Subject: Re: [PATCH] MM: Fix NR_SECTION_ROOTS == 0 when using using sparsemem
	extreme.
Date: Wed, 5 May 2010 19:19:27 -0300
Message-ID: <n2pcecb6d8f1005051519ze48b22a0t8548311839f510b0@mail.gmail.com>
References: <1273093366-3388-1-git-send-email-mroberto@cpti.cetuc.puc-rio.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1273093366-3388-1-git-send-email-mroberto@cpti.cetuc.puc-rio.br>
Sender: linux-kernel-owner@vger.kernel.org
To: mroberto@cpti.cetuc.puc-rio.br, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

I have done a limited test of the patch, I don't think the actual code
has been reached, any help would be appreciated.

I did a small patch to /proc/meminfo to check that NR_SECTION_ROOTS is
now non-zero:

$ cat /proc/meminfo
NR_SECTION_ROOTS=1
NR_MEM_SECTIONS=32
SECTIONS_PER_ROOT=512
SECTIONS_SHIFT=5
MAX_PHYSMEM_BITS=32
SECTION_SIZE_BITS=27
...

On Wed, May 5, 2010 at 18:02, Marcelo Roberto Jimenez
<mroberto@cpti.cetuc.puc-rio.br> wrote:
> Got this while compiling for ARM/SA1100:
>
> mm/sparse.c: In function '__section_nr':
> mm/sparse.c:135: warning: 'root' is used uninitialized in this function
>
> This patch follows Russell King's suggestion for a new calculation for
> NR_SECTION_ROOTS. Thanks also to Sergei Shtylyov for pointing out the
> existence of the macro DIV_ROUND_UP.
>
> Signed-off-by: Marcelo Roberto Jimenez <mroberto@cpti.cetuc.puc-rio.br>
