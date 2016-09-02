From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v2 05/20] x86: Add the Secure Memory Encryption cpu
	feature
Date: Fri, 2 Sep 2016 16:09:13 +0200
Message-ID: <20160902140913.GA23808@nazgul.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
	<20160822223622.29880.17779.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160822223622.29880.17779.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
Cc: linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: linux-mm.kvack.org

On Mon, Aug 22, 2016 at 05:36:22PM -0500, Tom Lendacky wrote:
> Update the cpu features to include identifying and reporting on the
> Secure Memory Encryption feature.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  arch/x86/include/asm/cpufeature.h        |    7 +++++--
>  arch/x86/include/asm/cpufeatures.h       |    5 ++++-
>  arch/x86/include/asm/disabled-features.h |    3 ++-
>  arch/x86/include/asm/required-features.h |    3 ++-
>  arch/x86/kernel/cpu/scattered.c          |    1 +
>  5 files changed, 14 insertions(+), 5 deletions(-)

...

> diff --git a/arch/x86/kernel/cpu/scattered.c b/arch/x86/kernel/cpu/scattered.c
> index 8cb57df..d86d9a5 100644
> --- a/arch/x86/kernel/cpu/scattered.c
> +++ b/arch/x86/kernel/cpu/scattered.c
> @@ -37,6 +37,7 @@ void init_scattered_cpuid_features(struct cpuinfo_x86 *c)
>  		{ X86_FEATURE_HW_PSTATE,	CR_EDX, 7, 0x80000007, 0 },
>  		{ X86_FEATURE_CPB,		CR_EDX, 9, 0x80000007, 0 },
>  		{ X86_FEATURE_PROC_FEEDBACK,	CR_EDX,11, 0x80000007, 0 },
> +		{ X86_FEATURE_SME,		CR_EAX, 0, 0x8000001f, 0 },

If this is in scattered CPUID features, it doesn't need any of the
(snipped) changes above - you solely need to reuse one of the free
defines, i.e., something like this:

---
--- a/arch/x86/include/asm/cpufeatures.h	2016-09-02 15:49:08.853374323 +0200
+++ b/arch/x86/include/asm/cpufeatures.h	2016-09-02 15:52:34.477365610 +0200
@@ -100,7 +100,7 @@
 #define X86_FEATURE_XTOPOLOGY	( 3*32+22) /* cpu topology enum extensions */
 #define X86_FEATURE_TSC_RELIABLE ( 3*32+23) /* TSC is known to be reliable */
 #define X86_FEATURE_NONSTOP_TSC	( 3*32+24) /* TSC does not stop in C states */
-/* free, was #define X86_FEATURE_CLFLUSH_MONITOR ( 3*32+25) * "" clflush reqd with monitor */
+#define X86_FEATURE_SME		( 3*32+25) /* Secure Memory Encryption */
 #define X86_FEATURE_EXTD_APICID	( 3*32+26) /* has extended APICID (8 bits) */
 #define X86_FEATURE_AMD_DCM     ( 3*32+27) /* multi-node processor */
 #define X86_FEATURE_APERFMPERF	( 3*32+28) /* APERFMPERF */
--- a/arch/x86/kernel/cpu/scattered.c	2016-09-02 15:48:52.753375005 +0200
+++ b/arch/x86/kernel/cpu/scattered.c	2016-09-02 15:51:32.437368239 +0200
@@ -37,6 +37,7 @@ void init_scattered_cpuid_features(struc
 		{ X86_FEATURE_HW_PSTATE,	CR_EDX, 7, 0x80000007, 0 },
 		{ X86_FEATURE_CPB,		CR_EDX, 9, 0x80000007, 0 },
 		{ X86_FEATURE_PROC_FEEDBACK,	CR_EDX,11, 0x80000007, 0 },
+		{ X86_FEATURE_SME,		CR_EAX, 0, 0x8000001f, 0 },
 		{ 0, 0, 0, 0, 0 }
 	};

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
