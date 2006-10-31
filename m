Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id k9VGsdNU022511
	for <linux-mm@kvack.org>; Tue, 31 Oct 2006 08:54:41 -0800
Received: from nf-out-0910.google.com (nfca4.prod.google.com [10.48.103.4])
	by zps36.corp.google.com with ESMTP id k9VGsYpL027228
	for <linux-mm@kvack.org>; Tue, 31 Oct 2006 08:54:37 -0800
Received: by nf-out-0910.google.com with SMTP id a4so332493nfc
        for <linux-mm@kvack.org>; Tue, 31 Oct 2006 08:54:34 -0800 (PST)
Message-ID: <6599ad830610310854ke6bac53sf1be893efc0d5942@mail.gmail.com>
Date: Tue, 31 Oct 2006 08:54:34 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [ckrm-tech] RFC: Memory Controller
In-Reply-To: <4547305A.9070903@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061030103356.GA16833@in.ibm.com> <4545D51A.1060808@in.ibm.com>
	 <4546212B.4010603@openvz.org> <454638D2.7050306@in.ibm.com>
	 <45470DF4.70405@openvz.org> <45472B68.1050506@in.ibm.com>
	 <4547305A.9070903@openvz.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelianov <xemul@openvz.org>
Cc: balbir@in.ibm.com, vatsa@in.ibm.com, dev@openvz.org, sekharan@us.ibm.com, ckrm-tech@lists.sourceforge.net, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, pj@sgi.com, matthltc@us.ibm.com, dipankar@in.ibm.com, rohitseth@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10/31/06, Pavel Emelianov <xemul@openvz.org> wrote:
>
> Paul Menage won't agree. He believes that interface must come first.

No, I'm just trying to get agreement on the generic infrastructure for
process containers and extensibility - the actual API to the memory
controller (i.e. what limits, what to track, etc) can presumably be
fitted into  the generic mechanism fairly easily (or else the
infrastructure probably isn't generic enough).

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
