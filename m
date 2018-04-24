Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6BFF36B0009
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 10:35:26 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id v23-v6so17753094iog.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 07:35:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x22-v6sor950339itc.44.2018.04.24.07.35.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 07:35:21 -0700 (PDT)
Subject: Re: [PATCH 9/9] Protect SELinux initialized state with pmalloc
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
 <20180423125458.5338-10-igor.stoppa@huawei.com>
 <13ee6991-db48-d484-66a6-90de45fad2df@tycho.nsa.gov>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <34d804c6-8aea-52ee-41b8-139aaf188d80@gmail.com>
Date: Tue, 24 Apr 2018 18:35:18 +0400
MIME-Version: 1.0
In-Reply-To: <13ee6991-db48-d484-66a6-90de45fad2df@tycho.nsa.gov>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Smalley <sds@tycho.nsa.gov>, willy@infradead.org, keescook@chromium.org, paul@paul-moore.com, mhocko@kernel.org, corbet@lwn.net
Cc: labbott@redhat.com, david@fromorbit.com, rppt@linux.vnet.ibm.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>



On 24/04/18 16:49, Stephen Smalley wrote:
> On 04/23/2018 08:54 AM, Igor Stoppa wrote:

[...]

>> The patch is probably in need of rework, to make it fit better with the
>> new SELinux internal data structures, however it shows how to deny an
>> easy target to the attacker.
> 
> I know this is just an example, but not sure why you wouldn't just protect the
> entire selinux_state.

Because I have much more to discuss about SELinux, which would involve 
the whole state, the policyDB and the AVC

I will start a separate thread about that. This was merely as simple as 
possible example of the use of the API.

I just wanted to have a feeling about how it would be received :-)

> Note btw that the selinux_state encapsulation is preparatory work
> for selinux namespaces [1], at which point the structure is in fact dynamically allocated
> and there can be multiple instances of it.  That however is work-in-progress, highly experimental,
> and might not ever make it upstream (if we can't resolve the various challenges it poses in a satisfactory
> way).

Yes, I am aware of this and I would like to discuss also in the light of 
the future directions.

I just didn't want to waste too much time on something that you might 
want to change radically in a month :-)

I already was caught once by surprise when ss_initalized disappeared 
just when I had a patch ready for it :-)

--
igor
