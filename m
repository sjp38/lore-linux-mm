Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1512A6B0253
	for <linux-mm@kvack.org>; Sat, 22 Oct 2016 06:09:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c78so7480992wme.4
        for <linux-mm@kvack.org>; Sat, 22 Oct 2016 03:09:02 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id ff10si6514518wjb.271.2016.10.22.03.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Oct 2016 03:09:01 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id f193so28013512wmg.0
        for <linux-mm@kvack.org>; Sat, 22 Oct 2016 03:09:00 -0700 (PDT)
Subject: Re: Rewording language in mbind(2) to "threads" not "processes"
References: <f3c4ca9d-a880-5244-e06e-db4725e4d945@gmail.com>
 <alpine.DEB.2.20.1610131314020.3176@east.gentwo.org>
 <CAKgNAkiMo-AMZ2PUm3A8NqfiNa+GOnRFn4NrFwjRJa8Z7xNsPw@mail.gmail.com>
 <67165fae-b965-eb34-ecf5-4247acaecee1@gmail.com>
 <alpine.DEB.2.20.1610210844120.24973@east.gentwo.org>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <f1390356-5b8a-9b8f-e426-ad820b484af1@gmail.com>
Date: Sat, 22 Oct 2016 12:08:59 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1610210844120.24973@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: mtk.manpages@gmail.com, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, mhocko@kernel.org, mgorman@techsingularity.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, linux-man <linux-man@vger.kernel.org>, Brice Goglin <Brice.Goglin@inria.fr>

On 10/21/2016 03:44 PM, Christoph Lameter wrote:
> On Fri, 21 Oct 2016, Michael Kerrisk (man-pages) wrote:
> 
>> Did you have any thoughts on my follow-on question below?
> 
> There was only one AFAICT?
> 
>>> Thanks. So, are all the other cases where I changed "process" to
>>> "thread" okay then?
> 
>>From what I see yes.
> 
> 

Thanks, Christoph. I've added a Reviewed-by from you.

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
