Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 63C466B0031
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 20:48:42 -0400 (EDT)
Message-ID: <5227D4CA.1040901@huawei.com>
Date: Thu, 5 Sep 2013 08:48:10 +0800
From: Libin <huawei.libin@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Documentation/kmemcheck: update kmemcheck documentation
References: <1377304261-24668-1-git-send-email-huawei.libin@huawei.com> <CAOJsxLFRSf89-eKnNdg_G-04k930c1wxVrbz1VD2x1khf+-x+Q@mail.gmail.com>
In-Reply-To: <CAOJsxLFRSf89-eKnNdg_G-04k930c1wxVrbz1VD2x1khf+-x+Q@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Rob Landley <rob@landley.net>, Vegard Nossum <vegardno@ifi.uio.no>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, wangyijing@huawei.com, guohanjun@huawei.com, Andrew Morton <akpm@linux-foundation.org>

On 2013/9/4 14:51, Pekka Enberg wrote:
> On Sat, Aug 24, 2013 at 3:31 AM, Libin <huawei.libin@huawei.com> wrote:
>> Kmemcheck configuration menu location correction in Documentation/
>> kmemcheck.txt
>>
>> Signed-off-by: Libin <huawei.libin@huawei.com>
> 
> Looks good to me. Andrew mind picking this up?
> 

Hi Pekka,
This patch has been added to next tree.
https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=cb18c5e2ed48d9fbbe863c7d80f84d1964d883a3

Thanks!
Libin

> Acked-by: Pekka Enberg <penberg@kernel.org>
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
