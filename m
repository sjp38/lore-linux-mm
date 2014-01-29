Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f173.google.com (mail-ea0-f173.google.com [209.85.215.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5E4096B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 19:20:51 -0500 (EST)
Received: by mail-ea0-f173.google.com with SMTP id d10so569796eaj.4
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 16:20:50 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id y48si475896eew.184.2014.01.28.16.20.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jan 2014 16:20:50 -0800 (PST)
Message-ID: <52E84941.4080704@zytor.com>
Date: Tue, 28 Jan 2014 16:20:17 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC] shmgetfd idea
References: <52E709C0.1050006@linaro.org> <52E7298D.5020001@zytor.com> <52E80B85.8020302@linaro.org> <52E814FF.6060403@zytor.com> <52E819F0.6040806@linaro.org> <CAPXgP11Fv6TU+o2Eui5rVW0A37U7KjwC0DZYbQOJJ8rEAYOiJg@mail.gmail.com> <52E81BB3.6060306@linaro.org> <52E81CE2.3030304@zytor.com> <52E8271B.4030201@linaro.org> <CAPXgP13G14B3YFpaE+m_AtFfFR6NRVSi1JYAvLZSsfftSkgwBQ@mail.gmail.com> <52E83719.9060709@zytor.com> <CAPXgP116TBZx82=J_pKxgSqJsy4HY1nofMOkUtZELBYvcFhDcw@mail.gmail.com> <52E83AEB.4020809@zytor.com> <CAPXgP13u+0PCFsRDRFqSdopDuXyAvZCS2crOCDrPoT6m8Nq2Og@mail.gmail.com>
In-Reply-To: <CAPXgP13u+0PCFsRDRFqSdopDuXyAvZCS2crOCDrPoT6m8Nq2Og@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kay Sievers <kay@vrfy.org>
Cc: John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On 01/28/2014 04:14 PM, Kay Sievers wrote:
>>
>> If the "single owner" is determined by the file structure (e.g. via a
>> fcntl as opposed to a ioctl), then presumably we would simply deny an
>> attempt to open the inode and create a new file structure for it.
>>
>> On Linux, /proc/$PID/fd is an open as opposed to a dup (as much as I
>> personally don't like those semantics, they are well set in stone at
>> this point) so it satisfies your requirements.
> 
> If that all could be made working, for the kdbus case we would be fine
> with requiring *any* tmpfs mount, create a new memfd from there with
> O_TMPFILE, and use new fcntl() definitios to protect/seal/unseal and
> identify that fd.
> 
> For the more restricted cases like Android that tmpfs mount could get
> a mount option to not allow the creation of any non-unlinked file, I
> guess.
> 

Right, that would be the idea.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
