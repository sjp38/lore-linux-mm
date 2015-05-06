Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id CB81A6B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 06:57:10 -0400 (EDT)
Received: by wizk4 with SMTP id k4so197135155wiz.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 03:57:10 -0700 (PDT)
Received: from ares41.inai.de (ares40.inai.de. [2a01:4f8:141:23c8::40])
        by mx.google.com with ESMTPS id 2si10490512wjq.85.2015.05.06.03.57.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 03:57:09 -0700 (PDT)
Date: Wed, 6 May 2015 12:57:08 +0200 (CEST)
From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [RFC] kernel random segmentation fault?
In-Reply-To: <55498EB0.3080904@huawei.com>
Message-ID: <alpine.LSU.2.20.1505061255360.8975@nerf40.vanv.qr>
References: <1430882810-225406-1-git-send-email-long.wanglong@huawei.com> <55498EB0.3080904@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "long.wanglong" <long.wanglong@huawei.com>
Cc: torvalds@linux-foundation.org, jay.foad@gmail.com, cwhuang@android-x86.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, riel@redhat.com, sasha.levin@oracle.com, Michal Hocko <mhocko@suse.cz>, dave@stgolabs.net, koct9i@gmail.com, luto@amacapital.net, pfeiner@google.com, dh.herrmann@gmail.com, vishnu.ps@samsung.com, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Wang Kai <morgan.wang@huawei.com>, peifeiyue <peifeiyue@huawei.com>, linux-arch@vger.kernel.org


On Wednesday 2015-05-06 05:46, long.wanglong wrote:
>
>int main(int argc, char** argv)
>{
>    rlim.rlim_cur=20 MB;
>    rlim.rlim_max=20 MB;
>    ret = setrlimit(RLIMIT_AS, &rlim);
>    [...]
>    char tmp[20 MB];
>    for (i = 0; i < 20 MB; i++)
>        tmp[i]=1;

if tmp already takes 20 MB, where will the remainder of the program find
space if you only allow for 20 MB? This is bound to fail under normal
considerations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
