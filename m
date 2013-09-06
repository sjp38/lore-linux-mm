Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id AEADA6B0031
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 04:38:56 -0400 (EDT)
Message-ID: <5229949C.6090904@redhat.com>
Date: Fri, 06 Sep 2013 10:38:52 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2 v2] mm: allow to set overcommit ratio more precisely
References: <1376925478-15506-1-git-send-email-jmarchan@redhat.com> <1376925478-15506-2-git-send-email-jmarchan@redhat.com> <52287E66.9010107@redhat.com> <52289824.20000@intel.com> <5228999B.8010300@redhat.com> <20130905221140.GA29867@amd.pavel.ucw.cz>
In-Reply-To: <20130905221140.GA29867@amd.pavel.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/06/2013 12:11 AM, Pavel Machek wrote:
> hi!
> 
>>>> This patch adds the new overcommit_ratio_ppm sysctl variable that
>>>> allow to set overcommit ratio with a part per million precision.
>>>> The old overcommit_ratio variable can still be used to set and read
>>>> the ratio with a 1% precision. That way, overcommit_ratio interface
>>>> isn't broken in any way that I can imagine.
>>>
>>> Looks like a pretty sane solution.  Could you also make a Documentation/
>>> update, please?
>>
>> Damn! I forgot. Will do.
> 
> Actually... would something like overcommit_bytes be better interface? overcommit_pages?
> 
> If system would normally allow allocating "n" pages, with overcommit
> it would allow allocating "n + overcommit_pages" pages. That seems
> like right granularity...
> 

I don't know what do you mean by "normally".
Anyway, I've considered that option: my concern about mixing absolute and
proportional values is that they would diverge if the amount of ram varies
(e.g. memory hotplug or virt baloon driver).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
