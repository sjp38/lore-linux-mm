Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A89066B0038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 11:26:10 -0400 (EDT)
Received: by padj3 with SMTP id j3so69689658pad.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 08:26:10 -0700 (PDT)
Received: from lists.s-osg.org (lists.s-osg.org. [54.187.51.154])
        by mx.google.com with ESMTP id pc7si26885718pac.69.2015.06.02.08.26.08
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 08:26:09 -0700 (PDT)
Message-ID: <556DCB05.1010102@osg.samsung.com>
Date: Tue, 02 Jun 2015 09:25:57 -0600
From: Shuah Khan <shuahkh@osg.samsung.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH 3/3] Add tests for lock on fault
References: <1432908808-31150-1-git-send-email-emunson@akamai.com> <1432908808-31150-4-git-send-email-emunson@akamai.com>
In-Reply-To: <1432908808-31150-4-git-send-email-emunson@akamai.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Shuah Khan <shuahkh@osg.samsung.com>

On 05/29/2015 08:13 AM, Eric B Munson wrote:
> Test the mmap() flag, the mlockall() flag, and ensure that mlock limits
> are respected.  Note that the limit test needs to be run a normal user.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Shuah Khan <shuahkh@osg.samsung.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-api@vger.kernel.org
> ---
>  tools/testing/selftests/vm/Makefile         |   8 +-
>  tools/testing/selftests/vm/lock-on-fault.c  | 145 ++++++++++++++++++++++++++++
>  tools/testing/selftests/vm/on-fault-limit.c |  47 +++++++++
>  tools/testing/selftests/vm/run_vmtests      |  23 +++++
>  4 files changed, 222 insertions(+), 1 deletion(-)
>  create mode 100644 tools/testing/selftests/vm/lock-on-fault.c
>  create mode 100644 tools/testing/selftests/vm/on-fault-limit.c
> 
> diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
> index a5ce953..32f3d20 100644
> --- a/tools/testing/selftests/vm/Makefile
> +++ b/tools/testing/selftests/vm/Makefile
> @@ -1,7 +1,13 @@
>  # Makefile for vm selftests
>  
>  CFLAGS = -Wall
> -BINARIES = hugepage-mmap hugepage-shm map_hugetlb thuge-gen hugetlbfstest
> +BINARIES = hugepage-mmap
> +BINARIES += hugepage-shm
> +BINARIES += hugetlbfstest
> +BINARIES += lock-on-fault
> +BINARIES += map_hugetlb
> +BINARIES += on-fault-limit
> +BINARIES += thuge-gen
>  BINARIES += transhuge-stress
>  
>  all: $(BINARIES)
> diff --git a/tools/testing/selftests/vm/lock-on-fault.c b/tools/testing/selftests/vm/lock-on-fault.c
> new file mode 100644
> index 0000000..e6a9688

Hi Eric,

Could you please make sure make kselftest run from kernel main
Makefile works and tools/testing/selftests/kselftest_install.sh
works. For now you have to be in tools/testing/selftests to run
kselftest_install.sh

thanks,
-- Shuah


-- 
Shuah Khan
Sr. Linux Kernel Developer
Open Source Innovation Group
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com | (970) 217-8978

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
