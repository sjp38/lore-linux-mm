Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 4BAE86B005C
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 23:21:50 -0400 (EDT)
Received: by qafl39 with SMTP id l39so1791015qaf.9
        for <linux-mm@kvack.org>; Sat, 09 Jun 2012 20:21:49 -0700 (PDT)
Message-ID: <4FD412CB.9060809@gmail.com>
Date: Sat, 09 Jun 2012 23:21:47 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: oomkillers gone wild.
References: <20120604152710.GA1710@redhat.com> <alpine.DEB.2.00.1206041629500.7769@chino.kir.corp.google.com> <20120605174454.GA23867@redhat.com> <alpine.DEB.2.00.1206081313000.19054@chino.kir.corp.google.com> <20120608210330.GA21010@redhat.com> <alpine.DEB.2.00.1206091920140.7832@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206091920140.7832@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kosaki.motohiro@gmail.com

(6/9/12 10:21 PM), David Rientjes wrote:
> On Fri, 8 Jun 2012, Dave Jones wrote:
>
>>   >  On a system not under oom conditions, i.e. before you start trinity, can
>>   >  you send the output of
>>   >
>>   >  	cat /proc/$(pidof dbus-daemon)/oom_score{_adj,}
>>   >  	grep RSS /proc/$(pidof dbus-daemon)/status
>>
>> # cat /proc/$(pidof dbus-daemon)/oom_score{_adj,}
>> -900
>> 7441500919753
>> # grep RSS /proc/$(pidof dbus-daemon)/status
>> VmRSS:	    1660 kB
>
> I'm suspecting you don't have my patch that changes the type of the
> automatic variable in oom_badness() to signed.  Could you retry this with
> that patch or pull 3.5-rc2 which already includes it?

Yes. Dave (Jones), As far as parsed your log, you are using x86_64, right?
As far as my testing, current linus tree works fine at least normal case.
please respin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
