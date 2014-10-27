Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 012946B0070
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 23:23:39 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so2851903pdb.11
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 20:23:39 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id hs2si9363422pdb.222.2014.10.26.20.23.38
        for <linux-mm@kvack.org>;
        Sun, 26 Oct 2014 20:23:38 -0700 (PDT)
Message-ID: <544DBA03.1010709@intel.com>
Date: Mon, 27 Oct 2014 11:20:35 +0800
From: Ren Qiaowei <qiaowei.ren@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 05/12] x86, mpx: on-demand kernel allocation of bounds
 tables
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-6-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241257300.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1410241257300.5308@nanos>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On 10/24/2014 08:08 PM, Thomas Gleixner wrote:
> On Sun, 12 Oct 2014, Qiaowei Ren wrote:
>> +	/*
>> +	 * Go poke the address of the new bounds table in to the
>> +	 * bounds directory entry out in userspace memory.  Note:
>> +	 * we may race with another CPU instantiating the same table.
>> +	 * In that case the cmpxchg will see an unexpected
>> +	 * 'actual_old_val'.
>> +	 */
>> +	ret = user_atomic_cmpxchg_inatomic(&actual_old_val, bd_entry,
>> +					   expected_old_val, bt_addr);
>
> This is fully preemptible non-atomic context, right?
>
> So this wants a proper comment, why using
> user_atomic_cmpxchg_inatomic() is the right thing to do here.
>

Well, we will address it.

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
