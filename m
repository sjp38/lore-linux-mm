Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C7D8C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 08:26:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4773E20675
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 08:26:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Me7oLnU0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4773E20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1A4E6B0010; Tue, 14 May 2019 04:26:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCB5E6B0266; Tue, 14 May 2019 04:26:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6AEF6B0269; Tue, 14 May 2019 04:26:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 984E76B0010
	for <linux-mm@kvack.org>; Tue, 14 May 2019 04:26:15 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id e129so11812622iof.16
        for <linux-mm@kvack.org>; Tue, 14 May 2019 01:26:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=4GwONZKT5RET7N6PWlM860uaduZb6+5QuVv3rFgtIho=;
        b=DeYBMWfBQiNWsQw/m3u9/UljGBFTv5XbQ1PPoV3WJSJjnn8WVmL4dgMhn4qvWEoXjU
         3tb5cwBvnyl2lg9O3gobXnV9hbY9jz6g9Bu7zLFoXfWTzSlLffZKWGFmS15g8mQ5DQ7C
         2E7QuMOPjsTVqrqPI49u4Jo4y12eZJfhvELqDZwnMx+RmND+8uhxCjigseLencBAyqw8
         Es1r6QnZgSZEiu9ral+4SP2cAZ5FthhsCkggWKsgJ4AVv+5mtoW0WJWv8dso6ySSLwSf
         fBb37suxua2Ng9vG4tELoK95nrLhSvmN1xGRfcTJuO93cD9GQ3pZBBXwO15fvkSGtb79
         wwjw==
X-Gm-Message-State: APjAAAWcjHC5DCOw57ro9QUiqp+KtQkqhFpd37rEHHQFwLtbq0qoEh+a
	1EaZ1xsMOu9ZbF2wqTs8hCPYQLl2eUuNlXGknWVWo9JqAq4DH/A0+7LSCqK15g9J4/0YNYqeMaC
	+waHa5Q9SfGihllIsQhAUl48fcd2QL6vUewiYiD9a8lX7o+2YxKRsSfc3+JW3ZhDz7g==
X-Received: by 2002:a24:e3c6:: with SMTP id d189mr756272ith.145.1557822375301;
        Tue, 14 May 2019 01:26:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwy3CxL8/LYcSdnGAiXRYFKtYCc+9IEPfxusIplWosQX8exK+EcQBFKoHdX+yD0Lrd6QGEE
X-Received: by 2002:a24:e3c6:: with SMTP id d189mr756241ith.145.1557822374535;
        Tue, 14 May 2019 01:26:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557822374; cv=none;
        d=google.com; s=arc-20160816;
        b=gBdq5ZluPzjXTKJQTh8bpgIRWU59HzJXBWhgjuSD2rshClJ2MpZG4jwyZxoowt1+bi
         RHO/1SvYD6+KNQT9oHSTo+gkRCQA4lSYcTrzpHrQ6qRbwgcbbu16swftTSX1tndw/a8V
         ImoKUxsg1QWnhxCS51SEV9pnwUqQYVGp2XxocDmCJFiqnr2ekU/j908+PmZ84dFDHeNG
         aBcw76uNwiZ+qLLdPXussXxck7pAad0li+o1VaKF1HoXKJTSF6qtNi0d6idoaudQnY/m
         jL/vd1e0VAuRFMkMEmW3dGAd3F3d2Xvdll6HVngAqScdGfX1BExgxv3XnMV/UKFfcqYA
         VdOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=4GwONZKT5RET7N6PWlM860uaduZb6+5QuVv3rFgtIho=;
        b=ecukWJy6L0JjM9XAdBGOrUDQMt6cXAWmOjuj5xnrfHINXGbmEiXS25PQTtzYyFCw8E
         HC9RkOHb/3EQmn0nh+xxm3kL3j8zZ4wbSpHkgn4QRSgRLy91HqfbRzm8LURoYSKfc/3C
         O//PViMiSvXtMW3zPD7naeIlmf4uvfKrREI5wO0Jhzl01O9BmWNXW3h173QR6it+/svz
         d0AzCEydhGaCjEzWeyJ4pXgMUEwSFqQ191OB3LwRXIysYn2q3IRcjgxksNzuF/SQh9wz
         e4hPxbVi3zGqqw3YNFqaJ9ajlOlLUkaCZmgM4vPiiCx0RLO8kfWw+dSiCbw5Qbk4ZIA2
         zPXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Me7oLnU0;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id n82si9378759jan.24.2019.05.14.01.26.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 01:26:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Me7oLnU0;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4E8NRWe038322;
	Tue, 14 May 2019 08:26:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=4GwONZKT5RET7N6PWlM860uaduZb6+5QuVv3rFgtIho=;
 b=Me7oLnU0/rmmtbQAySa5AOY/0LStOilrC3J76991LQTTFatI8eSBS258oGayJxjOmJ/D
 yHWDyCS73SnTaafYTYObBvbUdom0TeUggz2cbj3NFCkO1ERgywX83bGDVXanVtBN1ADK
 rA9iUbU7+FYqBDOL8FnBoQQUrjXihLOaBqP3eCUS59RzXfix50RyTJXON2aGBWJKluN4
 nYFPxujFDsqwPztKIgZhuv4YbdpzXoGhW26Z4odBcUA885M8JB4OpiAy7A73R0NJiT0E
 Jao0Uz8of4JvQOSHd+YQqAK/xhBmvYcu6KHzbKIrQkMWK4Qd0qKc+Pxc/nzUYRNj0Iuo ag== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2sdnttm68s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 08:26:05 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4E8OA2d011637;
	Tue, 14 May 2019 08:26:05 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2sf3cn4jgq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 08:26:04 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4E8Q0LQ024611;
	Tue, 14 May 2019 08:26:00 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 01:26:00 -0700
Subject: Re: [RFC KVM 18/27] kvm/isolation: function to copy page table
 entries for percpu buffer
To: Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
        Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        jan.setjeeilers@oracle.com, Liran Alon <liran.alon@oracle.com>,
        Jonathan Adams <jwadams@google.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-19-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com>
 <20190514070941.GE2589@hirez.programming.kicks-ass.net>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <b8487de1-83a8-2761-f4a6-26c583eba083@oracle.com>
Date: Tue, 14 May 2019 10:25:56 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190514070941.GE2589@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905140062
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905140062
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/14/19 9:09 AM, Peter Zijlstra wrote:
> On Mon, May 13, 2019 at 11:18:41AM -0700, Andy Lutomirski wrote:
>> On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
>> <alexandre.chartre@oracle.com> wrote:
>>>
>>> pcpu_base_addr is already mapped to the KVM address space, but this
>>> represents the first percpu chunk. To access a per-cpu buffer not
>>> allocated in the first chunk, add a function which maps all cpu
>>> buffers corresponding to that per-cpu buffer.
>>>
>>> Also add function to clear page table entries for a percpu buffer.
>>>
>>
>> This needs some kind of clarification so that readers can tell whether
>> you're trying to map all percpu memory or just map a specific
>> variable.  In either case, you're making a dubious assumption that
>> percpu memory contains no secrets.
> 
> I'm thinking the per-cpu random pool is a secrit. IOW, it demonstrably
> does contain secrits, invalidating that premise.
> 

The current code unconditionally maps the entire first percpu chunk
(pcpu_base_addr). So it assumes it doesn't contain any secret. That is
mainly a simplification for the POC because a lot of core information
that we need, for example just to switch mm, are stored there (like
cpu_tlbstate, current_task...).

If the entire first percpu chunk effectively has secret then we will
need to individually map only buffers we need. The kvm_copy_percpu_mapping()
function is added to copy mapping for a specified percpu buffer, so
this used to map percpu buffers which are not in the first percpu chunk.

Also note that mapping is constrained by PTE (4K), so mapped buffers
(percpu or not) which do not fill a whole set of pages can leak adjacent
data store on the same pages.

alex.

