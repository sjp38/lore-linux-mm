Message-ID: <40365887.6020204@movaris.com>
Date: Fri, 20 Feb 2004 10:57:11 -0800
From: Kirk True <ktrue@movaris.com>
MIME-Version: 1.0
Subject: Re: LTP VM test slower under 2.6.3 than 2.4.20
References: <40363778.20900@movaris.com> <3800000.1077295177@[10.10.2.4]>
In-Reply-To: <3800000.1077295177@[10.10.2.4]>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: kernelnewbies <kernelnewbies@nl.linux.org>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

> A kernel profile might help.

Here's the profiles comparing the two versions. I don't understand why 
no "do_page_fault" shows up under 2.4.20 or why "gunzip" does.

Kirk

-------------------------------------------------



2.6.3:

# readprofile -r;./mem01;readprofile -m /boot/System.map-2.6.3 \
       >> captured_profile2.6.3

   1446 poll_idle                                 24.9310
      4 delay_tsc                                  0.1667
     71 do_page_fault                              0.0536
     41 schedule                                   0.0238
     13 __might_sleep                              0.0637
      1 prepare_to_wait                            0.0068
      1 put_files_struct                           0.0042
   3229 do_softirq                                16.3081
      1 run_timer_softirq                          0.0022
   4807 total                                      0.0262



2.4.20:

# readprofile -r;./mem01;readprofile -m /boot/System.map-2.4.20 \
       >> captured_profile2.4.20

    347 gunzip                                     0.1559
      8 acpi_restore_state_mem                     0.0021
      2 proc_dostring                              0.0033
      3 access_process_vm                          0.0054
      2 __mod_timer                                0.0038
      1 del_timer                                  0.0065
      1 update_one_process                         0.0036
      1 notifier_chain_unregister                  0.0052
    365 total                                      0.0020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
