Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C24A6B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 05:28:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so174726wmz.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 02:28:42 -0700 (PDT)
Received: from mx04-000ceb01.pphosted.com (mx0b-000ceb01.pphosted.com. [67.231.152.126])
        by mx.google.com with ESMTPS id f1si24721062wmi.89.2016.08.17.02.28.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 02:28:41 -0700 (PDT)
Subject: Re: OOM killer changes
References: <20160801202616.GG31957@dhcp22.suse.cz>
 <b91f97ee-c369-43be-c934-f84b96260ead@Quantum.com>
 <27bd5116-f489-252c-f257-97be00786629@Quantum.com>
 <20160802071010.GB12403@dhcp22.suse.cz>
 <ccad54a2-be1e-44cf-b9c8-d6b34af4901d@quantum.com>
 <6cb37d4a-d2dd-6c2f-a65d-51474103bf86@Quantum.com>
 <d1f63745-b9e3-b699-8a5a-08f06c72b392@suse.cz>
 <20160815150123.GG3360@dhcp22.suse.cz>
 <1b8ee89d-a851-06f0-6bcc-62fef9e7e7cc@Quantum.com>
 <20160816073246.GC5001@dhcp22.suse.cz> <20160816074316.GD5001@dhcp22.suse.cz>
 <6a22f206-e0e7-67c9-c067-73a55b6fbb41@Quantum.com>
 <a61f01eb-7077-07dd-665a-5125a1f8ef37@suse.cz>
From: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Message-ID: <0325d79b-186b-7d61-2759-686f8afff0e9@Quantum.com>
Date: Wed, 17 Aug 2016 02:28:35 -0700
MIME-Version: 1.0
In-Reply-To: <a61f01eb-7077-07dd-665a-5125a1f8ef37@suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On 17.08.2016 02:23, Vlastimil Babka wrote:
> On 08/17/2016 11:14 AM, Ralf-Peter Rohbeck wrote:
>> On 16.08.2016 00:43, Michal Hocko wrote:
>>> On Tue 16-08-16 09:32:46, Michal Hocko wrote:
>>>> On Mon 15-08-16 11:42:11, Ralf-Peter Rohbeck wrote:
>>>>> This time the OOM killer hit much quicker. No btrfs balance, just 
>>>>> compiling
>>>>> the kernel with the new change did it.
>>>>> Much smaller logs so I'm attaching them.
>>>> Just to clarify. You have added the trace_printk for
>>>> try_to_release_page, right? (after fixing it of course). If yes 
>>>> there is
>>>> no single mention of that path failing which would support Joonsoo's
>>>> theory... Could you try with his patch?
>>> And then it would be great if you could test with the current 
>>> linux-next
>>> tree. Vlastimil has done some changes which might help. But even if 
>>> they
>>> don't then it would be better to add more changes on top of them.
>>
>> Results with 4.8.0-rc2 are attached. OOM happened rather quickly.
>
> 4.8.0-rc2 is not "linux-next". What Michal meant is the linux-next git 
> (there's no tarball on kernel.org for it):
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git

Hmm. I added linux-next git, fetched it etc but apparently I didn't 
check out the right branch. Do you want next-20160817?

----------------------------------------------------------------------
The information contained in this transmission may be confidential. Any disclosure, copying, or further distribution of confidential information is not permitted unless such privilege is explicitly granted in writing by Quantum. Quantum reserves the right to have electronic communications, including email and attachments, sent across its networks filtered through anti virus and spam software programs and retain such messages in order to comply with applicable data security and retention requirements. Quantum is not responsible for the proper and complete transmission of the substance of this communication or for any delay in its receipt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
