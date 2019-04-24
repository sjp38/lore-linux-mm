Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C318C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 02:15:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9459F21773
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 02:15:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9459F21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6C5E6B0005; Tue, 23 Apr 2019 22:15:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1B116B0006; Tue, 23 Apr 2019 22:15:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C312F6B0007; Tue, 23 Apr 2019 22:15:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 743696B0005
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 22:15:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e9so2342249edn.8
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 19:15:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=KpKODcCPX9oVYO5qiCERLMJ95E3nSYNBUGEVcMW5myw=;
        b=JxdGR5bai5tHwJNiVhTYVtGCrrKcc1blDJLm6/LqM3zOsWTlCThhbeuFC2M/lVmD8C
         Q4mcJOmtWtEijpBAzg/RtbEjSCq0Tb8LTQMWOWLV8NFTw6YiOW6Am5iH52ArsUqzy5fv
         XuGjGh7bdEWGqV7EeJ47CdpK7xhCHdLYx1PYx7OgUvoFn1OELvfZt2ZMA0jfQfetSt/3
         FCBVvuh/IgbIkca7zKq80jflLNEAsFKKlXm6JwC3zMcLL/wsdRIN5jkkJyxK7GxfDMym
         5UOeZpH9ViR9Ohc/QjU6JPFF1L+E7f0ZZ1o7fmzad6ac9LNYSBIKZKN/5riZNbhk/tf3
         314w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAUNNjWfMytrI35nlX5fd6M0OrwM5/ay3eblwoxbY8+j7RW9ZV05
	k1+GJ4/1kdGUIv0MEllgOIRc0Mb690wcnqWHJnZj0jjHUN3JxMmtWrndToTx2cP2tgYspw1d+wO
	pwtyPZ0SLUzKT9wSv11pu5CRMoAk9zmj10bngSdmYO3307gzXzcAhtmqnpnn8w+Q=
X-Received: by 2002:a50:ec85:: with SMTP id e5mr18551293edr.232.1556072155852;
        Tue, 23 Apr 2019 19:15:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMtakYWcE8ACctiXf/9A2+Ha53qBPbhMxykT7mRr6+N+LooeNrcpU/ApDUnNCj66L1mfZ8
X-Received: by 2002:a50:ec85:: with SMTP id e5mr18551257edr.232.1556072154756;
        Tue, 23 Apr 2019 19:15:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556072154; cv=none;
        d=google.com; s=arc-20160816;
        b=iEo+g9ZwqaZG/zEkeS/iHacakeFCzX79Hrgfj1XMUxOBronGlxCpwpfEM2mtswq5pf
         DTxJw5QwUEpyQr33ecETYeJage/kGl+NBgQb5sQic7PkuyI9+2KqJ+p6TccPWfdtuRdc
         V8Ze/qC3iSGlEg5IgTtxApEob0BPZFCVqXTCis1vixUv3uBiydBFLgLQnIjZT+nf4GT5
         lpDQugvKTmsDqZ6efV4t+fVaQ8rlkTonaeHk28CivxklExtOObqezuOuUtiFLbcy4tLj
         EOgjwDlOx5cfdHSVyyuRn3u+LNJouqtD4QcHmybojhm4LGSOKq9K5lvMxHXOM9lbwUk/
         WppA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:mail-followup-to
         :message-id:subject:cc:to:from:date;
        bh=KpKODcCPX9oVYO5qiCERLMJ95E3nSYNBUGEVcMW5myw=;
        b=n8O+1CE86ygHzMBsgUcBU+Wepoy2fME4nf3anCPBHXEX7cHGnvrJJ7BJVH8M6No0Rd
         t+oLj6qCVgzu650hJ0RF4dwO3TztHU9K6KAPANeb5R3pjtKruiIhV8nEkMWYpasgu4kZ
         KhAl9Qh/8alVI/GKsX7idlpe6m5XHVzBLcBCDXasGLlGzIAhmIP+159Y0J3uYB85WcA0
         fSDN03LYr37fL1OMqXeWr8qcRO/hkfzxQOx1vZOI+0eYLTEiVOrUiTpp+dRjrOYxasOH
         +GHNI5xqEd10lMGi8oe3TB61ez/SA+fpNolTy4MIAnWf7obUGj2yvfAz6asDzupCgc6/
         SIrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l5si366237ejd.325.2019.04.23.19.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 19:15:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9AF78AC63;
	Wed, 24 Apr 2019 02:15:53 +0000 (UTC)
Date: Tue, 23 Apr 2019 19:15:44 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>, akpm@linux-foundation.org,
	Alexey Kardashevskiy <aik@ozlabs.ru>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org,
	jgg@mellanox.com
Subject: Re: [PATCH 5/6] powerpc/mmu: drop mmap_sem now that locked_vm is
 atomic
Message-ID: <20190424021544.ygqa4hvwbyb6nuxp@linux-r8p5>
Mail-Followup-To: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	akpm@linux-foundation.org, Alexey Kardashevskiy <aik@ozlabs.ru>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>,
	linuxppc-dev@lists.ozlabs.org, jgg@mellanox.com
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
 <20190402204158.27582-6-daniel.m.jordan@oracle.com>
 <964bd5b0-f1e5-7bf0-5c58-18e75c550841@c-s.fr>
 <20190403164002.hued52o4mga4yprw@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20190403164002.hued52o4mga4yprw@ca-dmjordan1.us.oracle.com>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 03 Apr 2019, Daniel Jordan wrote:

>On Wed, Apr 03, 2019 at 06:58:45AM +0200, Christophe Leroy wrote:
>> Le 02/04/2019 =E0 22:41, Daniel Jordan a =E9crit=A0:
>> > With locked_vm now an atomic, there is no need to take mmap_sem as
>> > writer.  Delete and refactor accordingly.
>>
>> Could you please detail the change ?
>
>Ok, I'll be more specific in the next version, using some of your language=
 in
>fact.  :)
>
>> It looks like this is not the only
>> change. I'm wondering what the consequences are.
>>
>> Before we did:
>> - lock
>> - calculate future value
>> - check the future value is acceptable
>> - update value if future value acceptable
>> - return error if future value non acceptable
>> - unlock
>>
>> Now we do:
>> - atomic update with future (possibly too high) value
>> - check the new value is acceptable
>> - atomic update back with older value if new value not acceptable and re=
turn
>> error
>>
>> So if a concurrent action wants to increase locked_vm with an acceptable
>> step while another one has temporarily set it too high, it will now fail.
>>
>> I think we should keep the previous approach and do a cmpxchg after
>> validating the new value.

Wouldn't the cmpxchg alternative also be exposed the locked_vm changing bet=
ween
validating the new value and the cmpxchg() and we'd bogusly fail even when =
there
is still just because the value changed (I'm assuming we don't hold any loc=
ks,
otherwise all this is pointless).

   current_locked =3D atomic_read(&mm->locked_vm);
   new_locked =3D current_locked + npages;
   if (new_locked < lock_limit)
      if (cmpxchg(&mm->locked_vm, current_locked, new_locked) =3D=3D curren=
t_locked)
      	 /* ENOMEM */

>
>That's a good idea, and especially worth doing considering that an arbitra=
ry
>number of threads that charge a low amount of locked_vm can fail just beca=
use
>one thread charges lots of it.

Yeah but the window for this is quite small, I doubt it would be a real iss=
ue.

What if before doing the atomic_add_return(), we first did the racy new_loc=
ked
check for ENOMEM, then do the speculative add and cleanup, if necessary. Th=
is
would further reduce the scope of the window where false ENOMEM can occur.

>pinned_vm appears to be broken the same way, so I can fix it too unless so=
meone
>beats me to it.

This should not be a surprise for the rdma folks. Cc'ing Jason nonetheless.

Thanks,
Davidlohr

