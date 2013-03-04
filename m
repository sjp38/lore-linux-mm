Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id DC7526B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 00:50:58 -0500 (EST)
Date: Mon, 4 Mar 2013 16:15:16 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V1 08/24] powerpc: Use encode avpn where we need only
 avpn values
Message-ID: <20130304051516.GD27523@drongo>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1361865914-13911-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1361865914-13911-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Tue, Feb 26, 2013 at 01:34:58PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> In all these cases we are doing something similar to
> 
> HPTE_V_COMPARE(hpte_v, want_v) which ignores the HPTE_V_LARGE bit
> 
> With MPSS support we would need actual page size to set HPTE_V_LARGE
> bit and that won't be available in most of these cases. Since we are ignoring
> HPTE_V_LARGE bit, use the  avpn value instead. There should not be any change
> in behaviour after this patch.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Paul Mackerras <paulus@samba.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
