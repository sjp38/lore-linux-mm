Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 683F16B003A
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 11:15:30 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id f13so1364492vbg.28
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 08:15:29 -0700 (PDT)
Message-ID: <5166D390.8050704@gmail.com>
Date: Thu, 11 Apr 2013 11:15:28 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch 0/2] mm: Add parameters to make kernel behavior at
 memory error on dirty cache selectable
References: <51662D5B.3050001@hitachi.com>
In-Reply-To: <51662D5B.3050001@hitachi.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitsuhiro Tanino <mitsuhiro.tanino.gm@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, kosaki.motohiro@gmail.com

(4/10/13 11:26 PM), Mitsuhiro Tanino wrote:
> Hi All,
> Please find a patch set that introduces these new sysctl interfaces,
> to handle a case when an memory error is detected on dirty page cache.
> 
> - vm.memory_failure_dirty_panic

Panic knob is ok to me. However I agree with Andi. If we need panic know,
it should handle generic IO error and data lost.


> - vm.memory_failure_print_ratelimit
> - vm.memory_failure_print_ratelimit_burst

But this is totally silly. 
print_ratelimit might ommit important messages. Please do a right way.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
