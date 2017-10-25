Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 56D356B0253
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 12:53:37 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id h4so407654qtk.4
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 09:53:37 -0700 (PDT)
Received: from rcdn-iport-2.cisco.com (rcdn-iport-2.cisco.com. [173.37.86.73])
        by mx.google.com with ESMTPS id h73si2112168qke.124.2017.10.25.09.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Oct 2017 09:53:35 -0700 (PDT)
Subject: Re: Detecting page cache trashing state
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz>
 <150549651001.4512.15084374619358055097@takondra-t460s>
 <20170918163434.GA11236@cmpxchg.org>
 <acbf4417-4ded-fa03-7b8d-34dc0803027c@cisco.com>
From: Daniel Walker <danielwa@cisco.com>
Message-ID: <8be3f051-0858-c014-96a7-a1903f063980@cisco.com>
Date: Wed, 25 Oct 2017 09:53:35 -0700
MIME-Version: 1.0
In-Reply-To: <acbf4417-4ded-fa03-7b8d-34dc0803027c@cisco.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ruslan Ruslichenko -X (rruslich - GLOBALLOGIC INC at Cisco)" <rruslich@cisco.com>, Johannes Weiner <hannes@cmpxchg.org>, Taras Kondratiuk <takondra@cisco.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, xe-linux-external@cisco.com, linux-kernel@vger.kernel.org

On 09/28/2017 08:49 AM, Ruslan Ruslichenko -X (rruslich - GLOBALLOGIC 
INC at Cisco) wrote:
> Hi Johannes,
>
> Hopefully I was able to rebase the patch on top v4.9.26 (latest 
> supported version by us right now)
> and test a bit.
> The overall idea definitely looks promising, although I have one 
> question on usage.
> Will it be able to account the time which processes spend on handling 
> major page faults
> (including fs and iowait time) of refaulting page?

Johannes, did you get a chance to review the changes from Ruslan ?

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
