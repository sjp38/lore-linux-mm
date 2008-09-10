Received: by wf-out-1314.google.com with SMTP id 28so2614572wfc.11
        for <linux-mm@kvack.org>; Wed, 10 Sep 2008 01:53:23 -0700 (PDT)
Message-ID: <2f11576a0809100153k16d03a11r322081d5e19bf801@mail.gmail.com>
Date: Wed, 10 Sep 2008 17:53:22 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH][RFC] memory.min_usage again
In-Reply-To: <20080910084443.8F7D85ACE@siro.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071204040934.44AF41D0BA3@siro.lan>
	 <20080910084443.8F7D85ACE@siro.lan>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: linux-mm@kvack.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Hi

>> here's a patch to implement memory.min_usage,
>> which controls the minimum memory usage for a cgroup.
>>
>> it works similarly to mlock;
>> global memory reclamation doesn't reclaim memory from
>> cgroups whose memory usage is below the value.
>> setting it too high is a dangerous operation.
>>
>> it's against 2.6.24-rc3-mm2 + memory.swappiness patch i posted here yesterday.
>> but it's logically independent from the swappiness patch.
>>
>> todo:
>> - restrict non-root user's operation ragardless of owner of cgroupfs files?
>> - make oom killer aware of this?

This is  really no good patch description.
You should write
 - Why you think it is useful.
 - Who need it.

A reviewer oftern want check to match coder's intention and actual code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
