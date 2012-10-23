Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 38F656B0070
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 19:15:36 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id v13so5829539vbk.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 16:15:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1210231541350.1221@chino.kir.corp.google.com>
References: <CAGPN=9Qx1JAr6CGO-JfoR2ksTJG_CLLZY_oBA_TFMzA_OSfiFg@mail.gmail.com>
	<20121022173315.7b0da762@ilfaris>
	<20121022214502.0fde3adc@ilfaris>
	<20121022170452.cc8cc629.akpm@linux-foundation.org>
	<alpine.LNX.2.00.1210222059120.1136@eggly.anvils>
	<20121023110434.021d100b@ilfaris>
	<CAJL_dMvUktOx9BqFm5jn2JbWbL_RWH412rdU+=rtDUvkuaPRUw@mail.gmail.com>
	<alpine.DEB.2.00.1210231541350.1221@chino.kir.corp.google.com>
Date: Wed, 24 Oct 2012 02:15:34 +0300
Message-ID: <CAJL_dMtS-rc1b3s9YZ+9Eapc21vF06aCT23GV8eMp13ZxURvBA@mail.gmail.com>
Subject: Re: Major performance regressions in 3.7rc1/2
From: Anca Emanuel <anca.emanuel@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Julian Wollrath <jwollrath@web.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Patrik Kullman <patrik.kullman@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, Oct 24, 2012 at 1:42 AM, David Rientjes <rientjes@google.com> wrote:
> On Tue, 23 Oct 2012, Anca Emanuel wrote:
>
>> I have the same problem.
>> Reverting
>> https://github.com/torvalds/linux/commit/957f822a0ab95e88b146638bad6209bbc315bedd
>> solves the problem for me.
>>
>
> If you don't revert anything and do
>
>         echo 0 > /proc/sys/vm/zone_reclaim_mode
>
> after boot, does this also fix the issue?

Yes.
http://imgur.com/JJwiJ

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
